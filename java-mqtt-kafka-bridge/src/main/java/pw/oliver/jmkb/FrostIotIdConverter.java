package pw.oliver.jmkb;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.Iterator;
import java.util.LinkedList;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.google.gson.JsonParseException;
import com.google.gson.JsonParser;

/**
 * Helper class to extract a single or multiple {@code @iot.id}s from FROST's {@code @iot.navigationLinks}. 
 * @author Oliver
 *
 */
public class FrostIotIdConverter {

	private Logger logger = LoggerFactory.getLogger(this.getClass());
	
	/**
	 * Get a single or multiple {@code @iot.id}s from a given link.
	 * @param link The address to poll from
	 * @return A String containing a single {@code @iot.id} or a comma separated
	 * enumeration of multiple {@code @iot.id}s.
	 */
	public String getIotIds(String link) {
		if (link == null) {
			return null;
		}
		JsonObject jo = getJsonObjectFromNavigationLink(link);
		if (jo == null) {
			return link;
		}
		if (jo.has("@iot.id")) {
			// only a single @iot.id available
			return jo.get("@iot.id").getAsString();
		} else if (jo.has("value")) {
			// multiple @iot.ids available
			LinkedList<String> ll = new LinkedList<>();
			JsonArray ja = (JsonArray) jo.get("value");
			Iterator<?> it = ja.iterator();
			while (it.hasNext()) {
				ll.add(((JsonObject) it.next()).get("@iot.id").getAsString());
			}
			return String.join(",", ll);
		} else {
			return link;
		}
	}

	public JsonObject getJsonObjectFromNavigationLink(String link) {
		try {
			URL url = new URL(link);
			HttpURLConnection conn = (HttpURLConnection) url.openConnection();
			conn.setRequestMethod("GET");
			if (conn.getResponseCode() != 200) {
				return null;
			} else {
				BufferedReader reader = new BufferedReader((new InputStreamReader(conn.getInputStream())));
				StringBuilder sb = new StringBuilder();
				reader.lines().forEachOrdered(sb::append);
			
				return (JsonObject) new JsonParser().parse(sb.toString());
			}
		} catch (MalformedURLException e) {
			// Invalid parameter
			logger.warn("Invalid @iot.navigationLink {}", link, e);
		} catch (JsonParseException e) {
			// could not parse connection response as JSON Object
			logger.warn("Could not parse response of {} as JsonObject", link, e);
		} catch (IOException e) {
			// could not establish connection
			logger.warn("Could not establish connection to {}", link, e);
		}
		return null;
	}
	
}
