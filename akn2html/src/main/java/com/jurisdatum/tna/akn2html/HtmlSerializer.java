package com.jurisdatum.tna.akn2html;

import java.io.OutputStream;
import java.util.Properties;

import net.sf.saxon.s9api.Serializer.Property;

class HtmlSerializer extends AbstractSerializer {
	
	public HtmlSerializer(OutputStream output) {
		super(output);
	}
	
	private static final Properties properties = new Properties();
	static {
		properties.setProperty(Property.METHOD.toString(), "html");
//		properties.setProperty(Property.VERSION.toString(), "5");
		properties.setProperty(Property.INCLUDE_CONTENT_TYPE.toString(), "no");
		properties.setProperty(Property.INDENT.toString(), "yes");
	}

	@Override
	protected Properties getProperties() {
		return properties;
	}

}
