package com.jurisdatum.tna.akn2html;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Optional;

import javax.xml.transform.Source;
import javax.xml.transform.TransformerException;
import javax.xml.transform.URIResolver;
import javax.xml.transform.stream.StreamSource;

import net.sf.saxon.s9api.Processor;
import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.XdmAtomicValue;
import net.sf.saxon.s9api.XsltCompiler;
import net.sf.saxon.s9api.XsltExecutable;
import net.sf.saxon.s9api.XsltTransformer;

public class Akn2Html {
	
	private final XsltExecutable executable;
	
	private static class Importer implements URIResolver {
		@Override public Source resolve(String href, String base) throws TransformerException {
			InputStream file = getClass().getResourceAsStream("/" + href);
			return new StreamSource(file);
		}
	}

	public Akn2Html() throws IOException {
		Processor processor = new Processor(false);
		XsltCompiler compiler = processor.newXsltCompiler();
		compiler.setURIResolver(new Importer());
		InputStream file = getClass().getResourceAsStream("/akn2html.xsl");
		Source source = new StreamSource(file);
		try {
			executable = compiler.compile(source);
		} catch (SaxonApiException e) {
			throw new RuntimeException(e);
		} finally {
			file.close();
		}
	}
	
	private String cssPath;
	
	public Akn2Html withCssPath(String cssPath) {
		this.cssPath = cssPath;
		return this;
	}
	
	public void transform(InputStream akn, OutputStream html, Optional<Boolean> ldapp) throws SaxonApiException {
		XsltTransformer transform = executable.load();
		if (cssPath != null)
			transform.setParameter(new QName("css-path"), new XdmAtomicValue(cssPath));
		if (ldapp.isPresent())
			transform.setParameter(new QName("ldapp"), new XdmAtomicValue(ldapp.get()));
		Source source = new StreamSource(akn);
		HtmlSerializer destination = new HtmlSerializer(html);
		transform.setSource(source);
		transform.setDestination(destination);
		transform.transform();
	}
	public void transform(InputStream akn, OutputStream html) throws SaxonApiException {
		transform(akn, html, Optional.empty());
	}

}
