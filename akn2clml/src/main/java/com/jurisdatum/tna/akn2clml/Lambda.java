package com.jurisdatum.tna.akn2clml;

import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.Map;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyRequestEvent;
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyResponseEvent;

public class Lambda implements RequestHandler<APIGatewayProxyRequestEvent, APIGatewayProxyResponseEvent> {

	private final LDAPP transform;

	public Lambda() throws IOException {
		transform = new LDAPP();
	}
	
	@Override
	public APIGatewayProxyResponseEvent handleRequest(APIGatewayProxyRequestEvent request, Context context) {
		String akn = request.getBody();
		if (akn == null) {
			Map<String, String> headers = new LinkedHashMap<>();
			headers.put("Content-Type", "text/plain");
			headers.put("Access-Control-Allow-Origin", "*");
			return new APIGatewayProxyResponseEvent()
				.withStatusCode(400)
				.withHeaders(headers)
				.withBody("body is empty");
		}
		Map<String, String> params = request.getQueryStringParameters();
		String isbn = params == null ? null : params.get("isbn");
		String clml;
		try {
			clml = transform.transform(akn, isbn);
		} catch (Exception e) {
			StringWriter sw = new StringWriter();
			PrintWriter pw = new PrintWriter(sw);
			e.printStackTrace(pw);
			String error = sw.toString();
			pw.close();
			try {
				sw.close();
			} catch (IOException e2) {
				e2.printStackTrace();
			}
			Map<String, String> headers = new LinkedHashMap<>();
			headers.put("Content-Type", "text/plain");
			headers.put("Access-Control-Allow-Origin", "*");
			return new APIGatewayProxyResponseEvent()
				.withStatusCode(500)
				.withHeaders(headers)
				.withBody(error);
		}
		Map<String, String> headers = new LinkedHashMap<>();
		headers.put("Content-Type", "application/xml");
		headers.put("Access-Control-Allow-Origin", "*");
		return new APIGatewayProxyResponseEvent()
			.withStatusCode(200)
			.withHeaders(headers)
			.withBody(clml);
	}

}
