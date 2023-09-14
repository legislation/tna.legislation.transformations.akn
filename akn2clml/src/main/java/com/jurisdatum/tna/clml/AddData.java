package com.jurisdatum.tna.clml;

import java.io.IOException;
import java.io.InputStream;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Map.Entry;

import javax.xml.transform.Source;
import javax.xml.transform.stream.StreamSource;

import com.jurisdatum.xml.Saxon;

import net.sf.saxon.s9api.Destination;
import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.XdmAtomicValue;
import net.sf.saxon.s9api.XdmEmptySequence;
import net.sf.saxon.s9api.XdmValue;
import net.sf.saxon.s9api.XsltCompiler;
import net.sf.saxon.s9api.XsltExecutable;
import net.sf.saxon.s9api.XsltTransformer;

public class AddData {

	private final static String defaultSchemaLocation = "http://www.legislation.gov.uk/schema/legislation.xsd";

	public static class Parameters {
		
		private String isbn = null;
		
		private boolean defaultPublisher = false;
		
		private String schemaLocation = null;
		
		public Parameters withIsbn(String isbn) {
			this.isbn = isbn;
			return this;
		}
		public Parameters withDefaultPublisher(boolean defaultPublisher) {
			this.defaultPublisher = defaultPublisher;
			return this;
		}
		public Parameters withSchemaLocation(String schemaLocation) {
			this.schemaLocation = schemaLocation;
			return this;
		}
		public Parameters withDefaultSchemaLocation() {
			return withSchemaLocation(defaultSchemaLocation);
		}
		
		private Map<QName, XdmValue> convert() {
			Map<QName, XdmValue> converted = new LinkedHashMap<>();
			if (isbn == null)
				converted.put(new QName("isbn"), XdmEmptySequence.getInstance());
			else
				converted.put(new QName("isbn"), new XdmAtomicValue(isbn));
			converted.put(new QName("default-publisher"), new XdmAtomicValue(defaultPublisher));
			XdmValue schemaLocationValue = schemaLocation == null ? XdmEmptySequence.getInstance() : new XdmAtomicValue(schemaLocation);
			converted.put(new QName("schemaLocation"), schemaLocationValue);
			return converted;
		}
	}
	
	private static final String stylesheet = "/transform/add-data.xsl";
	
	private final XsltExecutable executable;
	
	public AddData() throws IOException {
		XsltCompiler compiler = Saxon.processor.newXsltCompiler();
		InputStream stream = this.getClass().getResourceAsStream(stylesheet);
		Source source = new StreamSource(stream, "add-data.xsl");
		try {
			executable = compiler.compile(source);
		} catch (SaxonApiException e) {
			throw new RuntimeException(e);
		} finally {
			stream.close();
		}
	}
	
	public XsltTransformer load(Parameters params) {
		XsltTransformer transform = executable.load();
		for (Entry<QName, XdmValue> param : params.convert().entrySet())
			transform.setParameter(param.getKey(), param.getValue());
		return transform;
	}
	
	public void transform(Source akn, Destination destination, Parameters params) {
		XsltTransformer transform = load(params);
		try {
			transform.setSource(akn);
			transform.setDestination(destination);
			transform.transform();
		} catch (SaxonApiException e) {
			throw new RuntimeException(e);
		}
	}

}
