package com.jurisdatum.xml;

import java.util.Properties;

import javax.xml.transform.Result;

import net.sf.saxon.Configuration;
import net.sf.saxon.event.Emitter;
import net.sf.saxon.event.PipelineConfiguration;
import net.sf.saxon.event.Receiver;
import net.sf.saxon.s9api.Destination;
import net.sf.saxon.s9api.Processor;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.trans.XPathException;

public class Saxon {

	public static final Processor processor = new Processor(false);

	public static class SerializerFactory extends net.sf.saxon.event.SerializerFactory {

		@Override
		protected Emitter newXMLEmitter() {
			return new XMLEmitter();
		}

	}

	static {
		processor.getUnderlyingConfiguration().setSerializerFactory(new SerializerFactory());
	}
	
	public static Destination makeDestination(Result result, Properties props) {
		return new Destination() {
			public Receiver getReceiver(Configuration config) throws SaxonApiException {
				PipelineConfiguration pipe = new PipelineConfiguration();
				pipe.setConfiguration(config);
				try {
					return config.getSerializerFactory().getReceiver(result, pipe, props);
				} catch (XPathException e) {
					throw new RuntimeException(e);
				}
			}
		};
	}

}
