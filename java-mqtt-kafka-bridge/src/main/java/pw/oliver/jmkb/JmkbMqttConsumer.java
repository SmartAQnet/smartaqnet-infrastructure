package pw.oliver.jmkb;

import org.apache.avro.specific.SpecificRecordBase;
import org.eclipse.paho.client.mqttv3.IMqttDeliveryToken;
import org.eclipse.paho.client.mqttv3.MqttCallback;
import org.eclipse.paho.client.mqttv3.MqttClient;
import org.eclipse.paho.client.mqttv3.MqttConnectOptions;
import org.eclipse.paho.client.mqttv3.MqttException;
import org.eclipse.paho.client.mqttv3.MqttMessage;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

//TODO: correctly implement different producers

/**
 * This class is the MQTT consumer for the bridge.
 * It contains functionality to receive MQTT messages from the FROST server defined
 * in the properties file.<br>
 * Note that multiple instances of this class with the same clientId will behave the
 * same, possibly leading to duplicated Kafka records being sent.
 * 
 * @author Oliver
 */
public class JmkbMqttConsumer implements MqttCallback {

	private Logger logger = LoggerFactory.getLogger(this.getClass());
	
	private final String format;
	private final String clientId;
	private final JmkbKafkaProducer<?> producer;
	private MqttClient client;
	private MqttMessageConverter converter;
	
	/**
	 * The constructor for an AvroProducer
     * @param clientId The unique String identifier of this clientId.
     * @param producer The JmkbKafkaProducer at which the received message should be sent
	 */
	public <T> JmkbMqttConsumer(String clientId, JmkbKafkaProducer<T> producer) {
		this.format = PropertiesFileReader.getProperty("format");
		this.clientId = clientId;
		this.producer = producer;
		this.converter = new MqttMessageConverter();
		connect();
	}
	
	private void connect() {
		try {
			String frostServerURI = PropertiesFileReader.getProperty("frostServerURI");
			
			MqttConnectOptions options = new MqttConnectOptions();
			options.setCleanSession(true);
			this.client = new MqttClient(frostServerURI, clientId);
			client.setCallback(this);
			client.connect(options);
			logger.info("{} successfully connected to MQTT", clientId);
			client.subscribe("v1.0/Things");
			client.subscribe("v1.0/Datastreams");
			client.subscribe("v1.0/Locations");
			client.subscribe("v1.0/HistoricalLocations");
			client.subscribe("v1.0/Sensors");
			client.subscribe("v1.0/ObservedProperties");
			client.subscribe("v1.0/FeaturesOfInterest");
			client.subscribe("v1.0/Observations");
			logger.info("{} successfully subscribed to topics", clientId);
		} catch (MqttException e) {
			logger.warn("Could not initialize MQTT client {}", clientId, e);
		}
	}

	@Override
	public void connectionLost(Throwable cause) {
		logger.warn("{} lost connection to MQTT", clientId);
		try {
			// prevent spamming connect() on connection loss
			Thread.sleep(3000);
		} catch (InterruptedException e) {
			Thread.currentThread().interrupt();
			logger.debug("{} received interrupt while waiting for reconnect", clientId);
		}
		connect();
	}

	@Override
	public void messageArrived(String topic, MqttMessage message) throws Exception {
		new Thread() {
			
			@Override
			public void run() {
				logger.debug("Message arrived, topic \"{}\" message \"{}\"", topic, message);
				if (topic == null || message == null) {
					return;
				}
				String messageTopic = topic;
				// remove "v1.0/" from topic
				if (messageTopic.contains("/")) {
					messageTopic = messageTopic.split("/")[1];
				} else {
					logger.warn("Received message topic {} does not contain a slash! Message: {}", messageTopic, message);
					return;
				}
				// convert message and get key
				switch (format) {
				case "avro":
					SpecificRecordBase avroMessage = converter.mqttMessageToAvro(messageTopic, message);
					if (avroMessage != null) {
						String key = String.valueOf(avroMessage.get("iotId"));
						producer.send(messageTopic, key, avroMessage);
					}
					break;
				case "json":
					String jsonMessage = converter.mqttMessageToJson(messageTopic, message);
					String key = converter.getKeyFromMessage(message);
					producer.send(messageTopic, key, jsonMessage);
					logger.debug("Sent json message with topic \"{}\", key \"{}\" and message \"{}\"", messageTopic, key, jsonMessage);
					break;
				default:
					logger.warn("Conversion format not defined");
					break;
				}
			}
			
		}.start();
		
	}

	@Override
	public void deliveryComplete(IMqttDeliveryToken token) {
		// will not use, since we only consume
	}
	
	/**
	 * Disconnects the MQTT consumer from the server. This effectively destroys the consumer.
	 * New MQTT messages arriving after this method is called will not be processed.
	 */
	public void disconnect() {
		try {
			client.disconnect();
			client.close();
			logger.info("MQTT consumer {} has been closed", clientId);
		} catch (MqttException e) {
			logger.warn("Failed to close MQTT consumer {}", clientId, e);
		}
	}
}
