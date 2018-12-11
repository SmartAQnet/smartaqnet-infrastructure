package pw.oliver.jmkb;

import java.util.Properties;
import java.util.concurrent.TimeUnit;

import org.apache.avro.specific.SpecificRecordBase;
import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.kafka.common.serialization.StringSerializer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import io.confluent.kafka.serializers.KafkaAvroSerializer;

/**
 * This class is a Kafka record producer for the bridge.
 * It contains functionality to send Kafka records to the Kafka broker defined in the properties file.
 * This class sends Kafka records in the form of Avro objects (subclasses of {@link SpecificRecordBase}).
 * @author Oliver
 *
 */
public class JmkbKafkaAvroProducer implements JmkbKafkaProducer<SpecificRecordBase> {
	
	private Logger logger = LoggerFactory.getLogger(this.getClass());
	private KafkaProducer<String, SpecificRecordBase> producer;
	
	/**
	 * Constructor. Initializes the Kafka producer.
	 */
	public JmkbKafkaAvroProducer() {
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
		properties.put("value.serializer", KafkaAvroSerializer.class.getName());
		
		producer = new KafkaProducer<>(properties);
		logger.debug("Finished initializing Kafka producer");
	}
	
	/**
	 * Creates a Kafka record based on the given topic, key and SpecificRecordBase object.
	 * @param topic The topic of the record
	 * @param key The key of the record
	 * @param avroMessage The SpecificRecordBase to send
	 */
	@Override
	public <T> void send(String topic, String key, T avroMessage) {
		producer.send(new ProducerRecord<String, SpecificRecordBase>(topic, key, (SpecificRecordBase) avroMessage));
		producer.flush();
	}

	@Override
	public void disconnect() {
		producer.close(2, TimeUnit.SECONDS);
		logger.info("Kafka producer has been closed");
	}
}
