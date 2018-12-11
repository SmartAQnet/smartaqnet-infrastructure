package pw.oliver.jmkb;

import static org.junit.Assert.*;

import org.eclipse.paho.client.mqttv3.MqttMessage;
import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.Test;

public class MqttMessageConverterTest {

	@BeforeClass
	public static void setUpBeforeClass() throws Exception {
		PropertiesFileReader.init();
	}

	@AfterClass
	public static void tearDownAfterClass() throws Exception {
	}

	@Test
	public void testConstructor() {
		assertNotNull(new MqttMessageConverter());
	}

	@Test
	public void testMqttMessageToDatastreamsMinimal() {
		MqttMessageConverter conv = new MqttMessageConverter();
		byte[] payload = ("{\r\n" + 
				"  \"@iot.id\": \"D1\",\r\n" + 
				"  \"name\": \"A\",\r\n" + 
				"  \"description\": \"B\",\r\n" + 
				"  \"unitOfMeasurement\": {\r\n" + 
				"    \"name\": \"C\",\r\n" + 
				"    \"definition\": \"D\",\r\n" + 
				"    \"symbol\": \"E\"\r\n" + 
				"  },\r\n" + 
				"  \"observationType\": \"F\",\r\n" + 
				"  \"Thing@iot.navigationLink\": \"http://oliver.pw/singleID.json\",\r\n" + 
				"  \"ObservedProperty@iot.navigationLink\": \"http://oliver.pw/singleID.json\",\r\n" + 
				"  \"Sensor@iot.navigationLink\": \"http://oliver.pw/singleID.json\"\r\n" + 
				"}").getBytes();
		conv.mqttMessageToAvro("Datastreams", new MqttMessage(payload));
	}
	
	@Test
	public void testMqttMessageToDatastreamsFull() {
		MqttMessageConverter conv = new MqttMessageConverter();
		byte[] payload = ("{\r\n" + 
				"  \"@iot.id\": \"D1\",\r\n" + 
				"  \"name\": \"A\",\r\n" + 
				"  \"description\": \"B\",\r\n" + 
				"  \"unitOfMeasurement\": {\r\n" + 
				"    \"name\": \"C\",\r\n" + 
				"    \"definition\": \"D\",\r\n" + 
				"    \"symbol\": \"E\"\r\n" + 
				"  },\r\n" + 
				"  \"observedArea\": \"X1\",\r\n" + 
				"  \"phenomenonTime\": \"X2\",\r\n" + 
				"  \"resultTime\": \"X3\",\r\n" + 
				"  \"Observations@iot.navigationLink\": \"http://oliver.pw/multiID.json\"," + 
				"  \"observationType\": \"F\",\r\n" + 
				"  \"Thing@iot.navigationLink\": \"http://oliver.pw/singleID.json\",\r\n" + 
				"  \"ObservedProperty@iot.navigationLink\": \"http://oliver.pw/singleID.json\",\r\n" + 
				"  \"Sensor@iot.navigationLink\": \"http://oliver.pw/singleID.json\"\r\n" + 
				"}").getBytes();
		conv.mqttMessageToAvro("Datastreams", new MqttMessage(payload));
	}
	
	@Test
	public void testMqttMessageToSensorsMinimal() {
		MqttMessageConverter conv = new MqttMessageConverter();
		byte[] payload = ("{\r\n" + 
				"  \"@iot.id\": \"S1\",\r\n" + 
				"  \"name\": \"A\",\r\n" + 
				"  \"description\": \"B\",\r\n" + 
				"  \"encodingType\": \"C\",\r\n" + 
				"  \"metadata\": \"D\"\r\n" + 
				"}").getBytes();
		conv.mqttMessageToAvro("Sensors", new MqttMessage(payload));
	}
	
	@Test
	public void testMqttMessageToSensorsFull() {
		MqttMessageConverter conv = new MqttMessageConverter();
		byte[] payload = ("{\r\n" + 
				"  \"@iot.id\": \"S1\",\r\n" + 
				"  \"name\": \"A\",\r\n" + 
				"  \"description\": \"B\",\r\n" + 
				"  \"encodingType\": \"C\",\r\n" + 
				"  \"metadata\": \"D\",\r\n" + 
				"  \"Datastreams@iot.navigationLink\": \"http://oliver.pw/multiID.json\"" + 
				"}").getBytes();
		conv.mqttMessageToAvro("Sensors", new MqttMessage(payload));
	}
	
	@Test
	public void testMqttMessageToObservedPropertiesMinimal() {
		MqttMessageConverter conv = new MqttMessageConverter();
		byte[] payload = ("{\r\n" + 
				"  \"@iot.id\": \"OP1\",\r\n" + 
				"  \"name\": \"A\",\r\n" + 
				"  \"description\": \"B\",\r\n" + 
				"  \"definition\": \"C\"\r\n" + 
				"}").getBytes();
		conv.mqttMessageToAvro("ObservedProperties", new MqttMessage(payload));
	}
	
	@Test
	public void testMqttMessageToObservedPropertiesFull() {
		MqttMessageConverter conv = new MqttMessageConverter();
		byte[] payload = ("{\r\n" + 
				"  \"@iot.id\": \"OP1\",\r\n" + 
				"  \"name\": \"A\",\r\n" + 
				"  \"description\": \"B\",\r\n" + 
				"  \"definition\": \"C\",\r\n" + 
				"  \"Datastreams@iot.navigationLink\": \"http://oliver.pw/multiID.json\"\r\n" + 
				"}").getBytes();
		conv.mqttMessageToAvro("ObservedProperties", new MqttMessage(payload));
	}
	
	@Test
	public void testMqttMessageToObservationsMinimal() {
		MqttMessageConverter conv = new MqttMessageConverter();
		byte[] payload = ("{\r\n" + 
				"  \"@iot.id\": \"O1\",\r\n" + 
				"  \"phenomenonTime\": \"A\",\r\n" + 
				"  \"result\": \"B\",\r\n" + 
				"  \"resultTime\": \"C\",\r\n" + 
				"  \"Datastream@iot.navigationLink\": \"http://oliver.pw/singleID.json\"\r\n" + 
				"}").getBytes();
		conv.mqttMessageToAvro("Observations", new MqttMessage(payload));
	}
	
	@Test
	public void testMqttMessageToObservationsFull() {
		MqttMessageConverter conv = new MqttMessageConverter();
		byte[] payload = ("{\r\n" + 
				"  \"@iot.id\": \"O1\",\r\n" + 
				"  \"phenomenonTime\": \"A\",\r\n" + 
				"  \"result\": \"B\",\r\n" + 
				"  \"resultTime\": \"C\",\r\n" + 
				"  \"resultQuality\": \"X1\",\r\n" + 
				"  \"validTime\": \"X2\",\r\n" + 
				"  \"Datastream@iot.navigationLink\": \"http://oliver.pw/singleID.json\",\r\n" + 
				"  \"FeatureOfInterest@iot.navigationLink\": \"http://oliver.pw/singleID.json\"" + 
				"}").getBytes();
		conv.mqttMessageToAvro("Observations", new MqttMessage(payload));
	}
	
	@Test
	public void testMqttMessageToFeaturesOfInterestMinimal() {
		MqttMessageConverter conv = new MqttMessageConverter();
		byte[] payload = ("{\r\n" + 
				"  \"@iot.id\": \"FOI1\",\r\n" + 
				"  \"name\": \"A\",\r\n" + 
				"  \"description\": \"B\",\r\n" + 
				"  \"encodingType\": \"C\",\r\n" + 
				"  \"feature\": {\r\n" + 
				"    \"type\": \"Point\",\r\n" + 
				"    \"coordinates\": [-13.37, 42.42]\r\n" + 
				"  }\r\n" + 
				"}").getBytes();
		conv.mqttMessageToAvro("FeaturesOfInterest", new MqttMessage(payload));
	}
	
	@Test
	public void testMqttMessageToFeaturesOfInterestFull() {
		MqttMessageConverter conv = new MqttMessageConverter();
		byte[] payload = ("{\r\n" + 
				"  \"@iot.id\": \"FOI1\",\r\n" + 
				"  \"name\": \"A\",\r\n" + 
				"  \"description\": \"B\",\r\n" + 
				"  \"encodingType\": \"C\",\r\n" + 
				"  \"Observations@iot.navigationLink\": \"http://oliver.pw/multiID.json\"," + 
				"  \"feature\": {\r\n" + 
				"    \"type\": \"Point\",\r\n" + 
				"    \"coordinates\": [-13.37, 42.42]\r\n" + 
				"  }\r\n" + 
				"}").getBytes();
		conv.mqttMessageToAvro("FeaturesOfInterest", new MqttMessage(payload));
	}
	
	@Test
	public void testMqttMessageToThingsMinimal() {
		MqttMessageConverter conv = new MqttMessageConverter();
		byte[] payload = ("{\r\n" + 
				"  \"@iot.id\": \"T1\",\r\n" + 
				"  \"name\": \"A\",\r\n" + 
				"  \"description\": \"B\"\r\n" + 
				"}").getBytes();
		conv.mqttMessageToAvro("Things", new MqttMessage(payload));
	}
	
	@Test
	public void testMqttMessageToThingsFull() {
		MqttMessageConverter conv = new MqttMessageConverter();
		byte[] payload = ("{\r\n" + 
				"  \"@iot.id\": \"T1\",\r\n" + 
				"  \"name\": \"A\",\r\n" + 
				"  \"description\": \"B\",\r\n" + 
				"  \"Locations@iot.navigationLink\": \"http://oliver.pw/multiID.json\"," + 
				"  \"Datastreams@iot.navigationLink\": \"http://oliver.pw/multiID.json\"" + 
				"}").getBytes();
		conv.mqttMessageToAvro("Things", new MqttMessage(payload));
	}
	
	@Test
	public void testMqttMessageToHistoricalLocations() {
		MqttMessageConverter conv = new MqttMessageConverter();
		byte[] payload = ("{\r\n" + 
				"  \"@iot.id\": \"HL1\",\r\n" + 
				"  \"name\": \"A\",\r\n" + 
				"  \"description\": \"B\",\r\n" + 
				"  \"encodingType\": \"C\",\r\n" + 
				"  \"feature\": {\r\n" + 
				"    \"type\": \"Point\",\r\n" + 
				"    \"coordinates\": [-13.37, 42.42]\r\n" + 
				"  }\r\n" + 
				"}").getBytes();
		conv.mqttMessageToAvro("HistoricalLocations", new MqttMessage(payload));
	}
	
	@Test
	public void testMqttMessageToLocationsMinimal() {
		MqttMessageConverter conv = new MqttMessageConverter();
		byte[] payload = ("{\r\n" + 
				"  \"@iot.id\": \"L1\",\r\n" + 
				"  \"name\": \"A\",\r\n" + 
				"  \"description\": \"B\",\r\n" + 
				"  \"encodingType\": \"C\",\r\n" + 
				"  \"feature\": {\r\n" + 
				"    \"type\": \"Point\",\r\n" + 
				"    \"coordinates\": [-13.37, 42.42]\r\n" + 
				"  }\r\n" + 
				"}").getBytes();
		conv.mqttMessageToAvro("Locations", new MqttMessage(payload));
	}
	
	@Test
	public void testMqttMessageToLocationsFull() {
		MqttMessageConverter conv = new MqttMessageConverter();
		byte[] payload = ("{\r\n" + 
				"  \"@iot.id\": \"L1\",\r\n" + 
				"  \"name\": \"A\",\r\n" + 
				"  \"description\": \"B\",\r\n" + 
				"  \"encodingType\": \"C\",\r\n" + 
				"  \"Things@iot.navigationLink\": \"http://oliver.pw/multiID.json\"," + 
				"  \"feature\": {\r\n" + 
				"    \"type\": \"Point\",\r\n" + 
				"    \"coordinates\": [-13.37, 42.42]\r\n" + 
				"  }\r\n" + 
				"}").getBytes();
		conv.mqttMessageToAvro("Locations", new MqttMessage(payload));
	}
	
	@Test
	public void testMqttMessageToLocationsEmptyCoordinates() {
		MqttMessageConverter conv = new MqttMessageConverter();
		byte[] payload = ("{\r\n" + 
				"  \"@iot.id\": \"L1\",\r\n" + 
				"  \"name\": \"A\",\r\n" + 
				"  \"description\": \"B\",\r\n" + 
				"  \"encodingType\": \"C\",\r\n" + 
				"  \"feature\": {\r\n" + 
				"    \"type\": \"Point\",\r\n" + 
				"    \"coordinates\": []\r\n" + 
				"  }\r\n" + 
				"}").getBytes();
		conv.mqttMessageToAvro("Locations", new MqttMessage(payload));
	}
	
	@Test
	public void testMqttMessageToDefault() {
		MqttMessageConverter conv = new MqttMessageConverter();
		byte[] payload = ("{}").getBytes();
		conv.mqttMessageToAvro("PaVoS", new MqttMessage(payload));
	}
	
	@Test
	public void testInvalidJSON() {
		MqttMessageConverter conv = new MqttMessageConverter();
		byte[] payload = ("no-json-here->:(").getBytes();
		conv.mqttMessageToAvro("PaVoS", new MqttMessage(payload));
	}
	
	@Test
	public void testIncompleteJSON() {
		MqttMessageConverter conv = new MqttMessageConverter();
		byte[] payload = ("{}").getBytes();
		conv.mqttMessageToAvro("Things", new MqttMessage(payload));
	}

}
