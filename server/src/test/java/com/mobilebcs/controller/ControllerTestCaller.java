package com.mobilebcs.controller;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.ObjectWriter;
import org.springframework.http.MediaType;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;

public class ControllerTestCaller {

    private final MockMvc mockMvc;
    private final ObjectMapper objectMapper;


    public ControllerTestCaller(MockMvc mockMvc, ObjectMapper objectMapper) {
        this.mockMvc = mockMvc;
        this.objectMapper = objectMapper;;
    }

    public MockHttpServletResponse post(String path, Object body,Object... uriVariables) throws Exception {
        MockHttpServletRequestBuilder builder = MockMvcRequestBuilders.post(path, uriVariables).contentType(MediaType.APPLICATION_JSON).accept(new MediaType[]{MediaType.APPLICATION_JSON});

        if (body != null) {
            builder.content(this.convertToJson(body));
        }

        return this.mockMvc.perform(builder).andReturn().getResponse();
    }


    public MockHttpServletResponse getResponse(String path, Object... uriVariables) throws Exception {
        MockHttpServletRequestBuilder builder = MockMvcRequestBuilders.get(path, uriVariables);

        MvcResult mvcResult = this.mockMvc.perform(builder).andReturn();
      return mvcResult.getResponse();

    }



    private String convertToJson(Object requestBody) {
        return requestBody == null ? null : this.objectToJson(requestBody);
    }

    private String objectToJson(Object requestBody) {
        ObjectWriter ow = this.objectMapper.writer().withDefaultPrettyPrinter();

        try {
            return ow.writeValueAsString(requestBody);
        } catch (JsonProcessingException var4) {
            throw new RuntimeException(var4);
        }
    }
}
