package pw.oliver.jmkb;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.security.InvalidParameterException;
import java.util.Properties;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Helper class to read entries of the jmkb.properties file required for the bridge.
 * @author Oliver
 *
 */
public final class PropertiesFileReader {

	private static Logger logger = LoggerFactory.getLogger(PropertiesFileReader.class);
	private static Properties properties;
	private static boolean initialized = false;
	
	// prevent unwanted instantiation of utility class
	private PropertiesFileReader() {
		throw new AssertionError("Instantiating utility class!");
	}
	
	/**
	 * Read the properties file and check its values for validity.
	 * @return {@code true} if initialization was successful, {@code false} if not.
	 */
	public static boolean init() {
		/*
		if (initialized) {
			return true;
		}*/
		
		properties = new Properties();
		
		// check if properties file is missing keys
		try {
			FileInputStream fis = new FileInputStream("./jmkb.properties");
			properties.load(fis);
			fis.close();
			if (!properties.containsKey("frostServerURI")
					|| !properties.containsKey("kafkaBrokerURI")
					|| !properties.containsKey("schemaRegistryURI")
					|| !properties.containsKey("format")) {
				throw new InvalidParameterException();
			}
		} catch (InvalidParameterException e) {
			logger.error("The configuration file is missing at least one of the following required arguments:\n"
					+ "\t- frostServerURI\n"
					+ "\t- kafkaBrokerURI\n"
					+ "\t- schemaRegistryURI\n"
					+ "\t- format");
			return false;
		} catch (IOException e) {
			logger.error("There was an error reading the configuration file.\n"
					+ "Please make sure that there is a file named 'jmkb.properties' at "
					+ "the root directory of the program.");
			return false;
		}
		
		// check protocols of URIs
		// prepend tcp:// to frostServerURI if no protocol is defined (required for MQTT)
		if (!properties.getProperty("frostServerURI").contains("://")) {
			properties.setProperty("frostServerURI", "tcp://" + properties.getProperty("frostServerURI"));
		}
		if (!properties.getProperty("kafkaBrokerURI").contains("://")) {
			properties.setProperty("kafkaBrokerURI", "http://" + properties.getProperty("kafkaBrokerURI"));
		}
		if (!properties.getProperty("schemaRegistryURI").contains("://")) {
			properties.setProperty("schemaRegistryURI", "http://" + properties.getProperty("schemaRegistryURI"));
		}
		
		// check ports of URIs
		try {
			URI uriFrost  = new URI(properties.getProperty("frostServerURI"));
			URI uriKafka  = new URI(properties.getProperty("kafkaBrokerURI"));
			URI uriSchema = new URI(properties.getProperty("schemaRegistryURI"));

			// check if port for FROST was specified
			if (uriFrost.getPort() == -1) {
				logger.info("Bad URI format: No port defined for FROST-Server. Defaulting to port 1883");
				uriFrost = new URI(uriFrost.toString() + ":1883");
			}

			// check if port for Kafka was specified
			if (uriKafka.getPort() == -1) {
				logger.info("Bad URI format: No port defined for Kafka Broker. Defaulting to port 9092");
				uriKafka = new URI(uriKafka.toString() + ":9092");
			}

			// check if port for Schema Registry was specified
			if (uriSchema.getPort() == -1) {
				logger.info("Bad URI format: No port defined for the Schema Registry. Defaulting to port 8081");
				uriSchema = new URI(uriSchema.toString() + ":8081");
			}

			properties.setProperty("frostServerURI", uriFrost.toString());
			properties.setProperty("kafkaBrokerURI", uriKafka.toString());
			properties.setProperty("schemaRegistryURI", uriSchema.toString());
		} catch (URISyntaxException e) {
			logger.warn("Invalid URI specified.", e);
			return false;
		}
		
		try {
			FileOutputStream fos = new FileOutputStream("./jmkb.properties");
			properties.store(fos, null);
			fos.close();
		} catch (IOException e) {
			logger.warn("There was an error updating the configuration file.\n"
					+ "Please make sure that there is a file named 'jmkb.properties' at "
					+ "the root directory of the program.");
			return false;
		}
		initialized = true;
		return true;
	}
	
	/**
	 * Search for the value to a given key from the jmkb.properties file.
	 * Returns the value if the key is found, {@code null} if not.
	 * @param key The key of the property
	 * @return The value associated with the specified key
	 */
	public static String getProperty(String key) {
		if (initialized) {
			return properties.getProperty(key);
		}
		return null;
	}
}
