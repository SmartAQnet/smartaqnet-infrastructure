package pw.oliver.jmkb;

import static org.junit.Assert.*;

import org.apache.avro.specific.SpecificRecordBase;
import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.Test;

import pw.oliver.jmkb.avroclasses.ObservedProperty;

public class JmkbKafkaProducerTest {

	private static JmkbKafkaAvroProducer producer;
	private static SpecificRecordBase sr;
	
	@BeforeClass
	public static void setUpBeforeClass() throws Exception {
		PropertiesFileReader.init();
		JmkbKafkaAvroProducer producer = new JmkbKafkaAvroProducer();
		assertNotNull(producer);
		sr = ObservedProperty.newBuilder()
		.setIotId("testID")
		.setName("testName")
		.setDescription("For testing purposes")
		.setDefinition("Test")
		.setDatastreams("1,2,3,4")
		.build();
	}

	@AfterClass
	public static void tearDownAfterClass() throws Exception {
		producer.disconnect();
	}
	
	@Test
	public void testConstructor() {
		producer = new JmkbKafkaAvroProducer();
		assertNotNull(producer);
	}

	@Test
	public void testSend() {
		producer = new JmkbKafkaAvroProducer();
		producer.send("testTopic", "testKey", sr);
	}
	
}
