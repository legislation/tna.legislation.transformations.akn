package com.jurisdatum.tna.akn2clml;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

import javax.xml.transform.Result;
import javax.xml.transform.Source;
import javax.xml.transform.TransformerException;
import javax.xml.transform.URIResolver;
import javax.xml.transform.stream.StreamSource;

import com.jurisdatum.xml.Saxon;

import net.sf.saxon.s9api.Destination;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.Serializer.Property;
import net.sf.saxon.s9api.XsltCompiler;
import net.sf.saxon.s9api.XsltExecutable;
import net.sf.saxon.s9api.XsltTransformer;

public class Transform implements com.jurisdatum.xml.Transform {
	
	private static final String stylesheet = "/transform/akn2clml.xsl";
	
	private static class Importer implements URIResolver {
		@Override public Source resolve(String href, String base) throws TransformerException {
			InputStream file = this.getClass().getResourceAsStream("/transform/" + href);
			return new StreamSource(file, href);
		}
	}

	private final XsltExecutable executable;
	
	public Transform() throws IOException {
		XsltCompiler compiler = Saxon.processor.newXsltCompiler();
		compiler.setURIResolver(new Importer());
		InputStream stream = this.getClass().getResourceAsStream(stylesheet);
		Source source = new StreamSource(stream, "akn2clml.xsl");
		try {
			executable = compiler.compile(source);
		} catch (SaxonApiException e) {
			throw new RuntimeException(e);
		} finally {
			stream.close();
		}
	}
	
	void transform(Source akn, Destination destination) {
		XsltTransformer transform = executable.load();
		try {
			transform.setSource(akn);
			transform.setDestination(destination);
			transform.transform();
		} catch (SaxonApiException e) {
			throw new RuntimeException(e);
		}
	}
	
	static Properties properties = new Properties();
	static {
		properties.setProperty(Property.INDENT.toString(), "yes");
		properties.setProperty(Property.SAXON_SUPPRESS_INDENTATION.toString(), "{http://www.legislation.gov.uk/namespaces/legislation}Text");
	}
	
	public void transform(Source akn, Result clml) {
		Destination destination = Saxon.makeDestination(clml, properties);
		transform(akn, destination);
	}

}
