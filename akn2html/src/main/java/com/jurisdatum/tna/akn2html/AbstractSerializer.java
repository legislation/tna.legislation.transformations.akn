package com.jurisdatum.tna.akn2html;

import java.io.OutputStream;
import java.util.Properties;

import javax.xml.transform.Result;
import javax.xml.transform.stream.StreamResult;

import net.sf.saxon.Configuration;
import net.sf.saxon.event.PipelineConfiguration;
import net.sf.saxon.event.Receiver;
import net.sf.saxon.s9api.Destination;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.trans.XPathException;

abstract class AbstractSerializer implements Destination {
	
	private final Result result;
	protected abstract Properties getProperties();
	
	protected AbstractSerializer(Result result) {
		this.result = result;
	}
	protected AbstractSerializer(OutputStream output) {
		result = new StreamResult(output);
	}

	@Override
	public Receiver getReceiver(Configuration config) throws SaxonApiException {
		PipelineConfiguration pipe = new PipelineConfiguration();
		pipe.setConfiguration(config);
		Properties properties = getProperties();
		try {
			return config.getSerializerFactory().getReceiver(result, pipe, properties);
		} catch (XPathException e) {
			throw new RuntimeException(e);
		}
	}

}
