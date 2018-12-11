package pw.oliver.jmkb;

import java.util.Properties;
import java.util.concurrent.TimeUnit;

import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.kafka.common.serialization.StringSerializer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * This class is a Kafka record producer for the bridge.
 * It contains functionality to send Kafka records to the Kafka broker defined in the properties file.
 * This class sends Kafka records in the form of JSON Strings.
 * @author Oliver
 *
 */
public class JmkbKafkaJsonProducer implements JmkbKafkaProducer<String> {
	
	private Logger logger = LoggerFactory.getLogger(this.getClass());
	private KafkaProducer<String, String> producer;
	
	/**
	 * Constructor. Initializes the Kafka producer.
	 */
	public JmkbKafkaJsonProducer() {
		String kafkaBrokerURI = PropertiesFileReader.getProperty("kafkaBrokerURI");
		String schemaRegistryURI = PropertiesFileReader.getProperty("schemaRegistryURI");
		Properties properties = new Properties();
		properties.put("bootstrap.servers", kafkaBrokerURI);
		properties.put("acks", "all");
		properties.put("linger.ms", 10);
		properties.put("retries", 0);
		properties.put("schema.registry.url", schemaRegistryURI);
		properties.put("max.block.ms", 10000);
		properties.put("key.serializer", StringSerializer.class.getName());
		properties.put("value.serializer", StringSerializer.class.getName());
		
		producer = new KafkaProducer<>(properties);
		logger.debug("Finished initializing Kafka producer");
	}
	
	/**
	 * Creates a Kafka record based on the given topic, key and JSON-String.
	 * @param topic The topic of the record
	 * @param key The key of the record
	 * @param jsonMessage The JSON-String to send
	 */
	@Override
	public <T> void send(String topic, String key, T jsonMessage) {
		producer.send(new ProducerRecord<String, String>(topic, key, (String) jsonMessage));
		producer.flush();
	}

	@Override
	public void disconnect() {
		producer.close(2, TimeUnit.SECONDS);
		logger.info("Kafka producer has been closed");
	}
}
