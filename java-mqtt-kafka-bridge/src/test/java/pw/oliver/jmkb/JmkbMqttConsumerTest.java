package pw.oliver.jmkb;

import static org.junit.Assert.*;

import org.eclipse.paho.client.mqttv3.MqttMessage;
import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.Ignore;
import org.junit.Test;

@Ignore
public class JmkbMqttConsumerTest {

	private static JmkbMqttConsumer cons;
	private static JmkbKafkaProducer prod;
	
	@BeforeClass
	public static void setUpBeforeClass() throws Exception {
		PropertiesFileReader.init();
	}

	@AfterClass
	public static void tearDownAfterClass() throws Exception {
	}

	@Test
	public void testConstructor() {
		prod = new JmkbKafkaAvroProducer();
		cons = new JmkbMqttConsumer("testConsumer", prod);
		assertNotNull(cons);
		prod.disconnect();
		cons.disconnect();
	}
	
	@Test
	public void testConnectionLost() {
		prod = new JmkbKafkaAvroProducer();
		cons = new JmkbMqttConsumer("testConsumer", prod);
		cons.connectionLost(null);
		prod.disconnect();
		cons.disconnect();
	}
	
	@Test
	public void testMessageArrived() throws Exception {
		prod = new JmkbKafkaAvroProducer();
		cons = new JmkbMqttConsumer("testConsumer", prod);
		MqttMessage mm = new MqttMessage();
		mm.setPayload("{\"name\": \"test\"}".getBytes());
		cons.messageArrived("v1.0/null", mm);
		cons.messageArrived("v1.0/null", null);
		cons.messageArrived("null", mm);
		cons.messageArrived(null, mm);
		MqttMessage validThing = new MqttMessage();
		validThing.setPayload(("{\r\n" + 
				"  \"@iot.id\": \"T1\",\r\n" + 
				"  \"name\": \"A\",\r\n" + 
				"  \"description\": \"B\"\r\n" + 
				"}").getBytes());
		cons.messageArrived("v1.0/Things", validThing);
		prod.disconnect();
		cons.disconnect();
	}
	
	@Test
	public void testDeliveryComplete() {
		prod = new JmkbKafkaAvroProducer();
		cons = new JmkbMqttConsumer("testConsumer", prod);
		cons.deliveryComplete(null);
		prod.disconnect();
		cons.disconnect();
	}
	
	@Test
	public void testDisconnect() {
		prod = new JmkbKafkaAvroProducer();
		cons = new JmkbMqttConsumer("testDisconnect", prod);
		prod.disconnect();
		cons.disconnect();
	}

}
