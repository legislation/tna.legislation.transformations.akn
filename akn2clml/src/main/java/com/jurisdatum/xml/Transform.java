package com.jurisdatum.xml;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;

import javax.xml.transform.Result;
import javax.xml.transform.Source;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

public interface Transform {
	
	public void transform(Source akn, Result result);

	default public void transform(InputStream input, OutputStream output) {
		Source source = new StreamSource(input);
		Result result = new StreamResult(output);
		transform(source, result);
	}
	
	default public String transform(String source) {
		ByteArrayInputStream input = new ByteArrayInputStream(source.getBytes());
		ByteArrayOutputStream output = new ByteArrayOutputStream();
		transform(input, output);
		try {
			return output.toString("UTF-8");
		} catch (UnsupportedEncodingException e) {
			return output.toString();
		}
	}

}
