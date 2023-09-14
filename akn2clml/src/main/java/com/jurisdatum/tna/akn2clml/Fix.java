package com.jurisdatum.tna.akn2clml;

import java.io.IOException;
import java.io.InputStream;

import javax.xml.transform.Source;
import javax.xml.transform.stream.StreamSource;

import com.jurisdatum.xml.Saxon;

import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.XdmDestination;
import net.sf.saxon.s9api.XdmNode;
import net.sf.saxon.s9api.XsltCompiler;
import net.sf.saxon.s9api.XsltExecutable;
import net.sf.saxon.s9api.XsltTransformer;

class Fix {

	private static final String stylesheet = "/transform/ldapp-fix.xsl";
	
	private final XsltExecutable executable;
	
	Fix() throws IOException {
		XsltCompiler compiler = Saxon.processor.newXsltCompiler();
		InputStream stream = this.getClass().getResourceAsStream(stylesheet);
		Source source = new StreamSource(stream, "ldapp-fix.xsl");
		try {
			executable = compiler.compile(source);
		} catch (SaxonApiException e) {
			throw new RuntimeException(e);
		} finally {
			stream.close();
		}
	}
	
	XdmNode fix(Source akn) {
		XsltTransformer transform = executable.load();
		XdmDestination destination = new XdmDestination();
		try {
			transform.setSource(akn);
			transform.setDestination(destination);
			transform.transform();
		} catch (SaxonApiException e) {
			throw new RuntimeException(e);
		}
		return destination.getXdmNode();
	}

}
