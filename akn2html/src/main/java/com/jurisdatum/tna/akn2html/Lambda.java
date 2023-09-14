package com.jurisdatum.tna.akn2html;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.util.LinkedHashMap;
import java.util.Map;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyRequestEvent;
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyResponseEvent;

import net.sf.saxon.s9api.SaxonApiException;

public class Lambda implements RequestHandler<APIGatewayProxyRequestEvent, APIGatewayProxyResponseEvent> {
	
	private static final String CssPath = "https://akn2html.s3.eu-west-2.amazonaws.com/css/";

	private final Akn2Html transform;

	public Lambda() throws IOException {
		transform = new Akn2Html().withCssPath(CssPath);
	}
	
//	private boolean ldapp(APIGatewayProxyRequestEvent request) {
//		Map<String, String> queryParams = request.getQueryStringParameters();
//		if (queryParams == null)
//			return false;
//		return "true".equalsIgnoreCase(queryParams.get("ldapp"));
//	}
	
	private String transform(String akn) throws SaxonApiException {
		InputStream input = new ByteArrayInputStream(akn.getBytes());
		ByteArrayOutputStream output = new ByteArrayOutputStream();
		transform.transform(input, output);
		try {
			return output.toString("UTF-8");
		} catch (UnsupportedEncodingException e) {
			throw new RuntimeException(e);
		}
	}
	
	private APIGatewayProxyResponseEvent error(int status, String body) {
		Map<String, String> headers = new LinkedHashMap<>();
		headers.put("Content-Type", "text/plain");
//		headers.put("Access-Control-Allow-Origin", "*");
		return new APIGatewayProxyResponseEvent()
			.withStatusCode(status)
			.withHeaders(headers)
			.withBody(body);
	}

	private APIGatewayProxyResponseEvent success(String body) {
		Map<String, String> headers = new LinkedHashMap<>();
		headers.put("Content-Type", "text/html");
//		headers.put("Access-Control-Allow-Origin", "*");
		return new APIGatewayProxyResponseEvent()
			.withStatusCode(200)
			.withHeaders(headers)
			.withBody(body);
	}

	@Override
	public APIGatewayProxyResponseEvent handleRequest(APIGatewayProxyRequestEvent request, Context context) {
		String akn = request.getBody();
		if (akn == null) {
			return error(400, "body is empty");
		}
//		boolean ldapp = ldapp(request);
		String html;
		try {
			html = transform(akn);
		} catch (Exception e) {
			return error(500, e.getLocalizedMessage());
		}
		return success(html);
	}

}
