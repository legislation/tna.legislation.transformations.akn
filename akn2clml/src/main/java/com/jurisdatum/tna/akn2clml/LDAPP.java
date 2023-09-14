package com.jurisdatum.tna.akn2clml;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;

import javax.xml.transform.Result;
import javax.xml.transform.Source;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import com.jurisdatum.tna.clml.AddData;
import com.jurisdatum.tna.clml.AddData.Parameters;
import com.jurisdatum.xml.Saxon;

import net.sf.saxon.s9api.Destination;
import net.sf.saxon.s9api.XdmNode;
import net.sf.saxon.s9api.XsltTransformer;

public class LDAPP {
	
	private final Fix transform0;
	private final Transform transform1;
	private final AddData transform2;

	public LDAPP() throws IOException {
		transform0 = new Fix();
		transform1 = new Transform();
		transform2 = new AddData();
	}
	
	private void transform(Source akn, Destination destination, String isbn) {
		XdmNode fixed = transform0.fix(akn);
		Parameters params = new Parameters().withIsbn(isbn).withDefaultPublisher(true);
		XsltTransformer addData = transform2.load(params);
		addData.setDestination(destination);
		transform1.transform(fixed.asSource(), addData);
	}

	public void transform(Source akn, Result clml, String isbn) {
		Destination destination = Saxon.makeDestination(clml, Transform.properties);
		transform(akn, destination, isbn);
	}

	public void transform(InputStream akn, OutputStream clml, String isbn) {
		Source source = new StreamSource(akn);
		Result result = new StreamResult(clml);
		transform(source, result, isbn);
	}

	public String transform(String akn, String isbn) {
		ByteArrayInputStream input = new ByteArrayInputStream(akn.getBytes());
		ByteArrayOutputStream output = new ByteArrayOutputStream();
		transform(input, output, isbn);
		try {
			return output.toString("UTF-8");
		} catch (UnsupportedEncodingException e) {
			return output.toString();
		}
	}

}
