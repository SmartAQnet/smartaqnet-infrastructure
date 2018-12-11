package pw.oliver.jmkb;

import static org.junit.Assert.*;

import org.junit.Test;

public class FrostIotIdConverterTest {

	@Test
	public void testGetIotIds() {
		FrostIotIdConverter conv = new FrostIotIdConverter();
		assertNull(conv.getIotIds(null));
		assertNull(conv.getIotIds("notALink"));
		assertNull(conv.getIotIds("https://www.google.com/404"));	// response code != 200
		assertNull(conv.getIotIds("https://oliver.pw"));			// not a json object
		assertNull(conv.getIotIds("https://oliver.pw/noID.json"));	// no @iot.id
		assertEquals("testID", conv.getIotIds("https://oliver.pw/singleID.json"));
		assertEquals("one,two", conv.getIotIds("https://oliver.pw/multiID.json"));
		assertEquals("", conv.getIotIds("https://oliver.pw/multiIDempty.json"));
	}

}
