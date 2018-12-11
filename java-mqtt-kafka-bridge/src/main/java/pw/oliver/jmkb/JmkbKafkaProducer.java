package pw.oliver.jmkb;

/**
 * This interface defines a Kafka record producer for the bridge.
 * It defines functionality to send Kafka records to the Kafka broker defined in the properties file.
 * @author Oliver
 *
 */
public interface JmkbKafkaProducer<E> {
	
	/**
	 * Creates a Kafka record based on the given topic, key and object.
	 * @param topic The topic of the record
	 * @param key The key of the record
	 * @param value The object to send
	 */
	public <T> void send(String topic, String key, T value);
	
	/**
	 * Disconnects the Kafka producer from the Kafka broker. This effectively destroys the producer.
	 * Subsequent calls to {@link #send(String, String, Object)} will not work.
	 */
	public void disconnect();
}
