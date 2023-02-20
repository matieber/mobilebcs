package com.mobilebcs.controller.user;


import com.fasterxml.jackson.databind.ObjectMapper;
import com.mobilebcs.controller.ControllerTestCaller;
import com.mobilebcs.controller.qualifier.QualificationSessionController;
import com.mobilebcs.domain.exception.UserNonexistentException;
import com.mobilebcs.domain.user.UserQualificationSessionService;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mockito;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.test.context.junit.jupiter.SpringExtension;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.ArgumentMatchers.eq;


@ExtendWith(SpringExtension.class)
@WebMvcTest(controllers = QualificationSessionController.class)
class QualificationSessionControllerTest {


    public static final String LOCATION_CODE = "DEFAULT";
    private ControllerTestCaller controllerTestCaller;

    @MockBean
    private UserQualificationSessionService userQualificationSessionService;


    @Autowired
    private MockMvc mockMvc;

    private ObjectMapper objectMapper;

    @BeforeEach
    public void init() {
        objectMapper = new ObjectMapper();
        controllerTestCaller = new ControllerTestCaller(mockMvc, objectMapper);
    }


    @Test
    public void testJoinQualificationSession() throws Exception {

        String name = "Pedro";
        long qualificationSession = 1L;
        Mockito.when(userQualificationSessionService.joinQualificationSession(eq(name), eq(qualificationSession))).thenReturn(new UserResponse(name, UserType.QUALIFIER, qualificationSession));
        MockHttpServletResponse response = controllerTestCaller.put("/location/{locationCode}/user/{name}/qualificationSession/{qualificationSession}", null, LOCATION_CODE, name, qualificationSession);

        Assertions.assertEquals(200, response.getStatus());
        UserResponse user = objectMapper
                .readValue(response.getContentAsByteArray(), UserResponse.class);
        Assertions.assertNotNull(user);
        Assertions.assertEquals(name, user.getUsername());
        Assertions.assertEquals(UserType.QUALIFIER, user.getUserType());
        Assertions.assertEquals(qualificationSession, user.getQualificationSession());
    }


    @Test
    public void testJoinQualificationSessionWithError() throws Exception {

        String name = "Pedro";
        String errorMessage = "Error buscando usuario";
        Mockito.when(userQualificationSessionService.joinQualificationSession(eq(name), Mockito.isNotNull())).thenThrow(new RuntimeException(errorMessage));
        long qualificationSession = 1l;
        MockHttpServletResponse response = controllerTestCaller.put("/location/{locationCode}/user/{name}/qualificationSession/{qualificationSession}", null, LOCATION_CODE, name, qualificationSession);

        Assertions.assertEquals(500, response.getStatus());
        String actualError = response.getContentAsString();
        Assertions.assertEquals(errorMessage, actualError);

    }

    @Test
    public void testJoinQualificationSessionThatUserNotExist() throws Exception {
        String name = "Pedro";
        String errorMessage = "Usuario con nombre " + name + " no existe";
        Mockito.when(userQualificationSessionService.joinQualificationSession(eq(name), Mockito.isNotNull())).thenThrow(new UserNonexistentException(errorMessage));
        long qualificationSession = 1L;
        MockHttpServletResponse response = controllerTestCaller.put("/location/{locationCode}/user/{name}/qualificationSession/{qualificationSession}", null, LOCATION_CODE, name, qualificationSession);

        Assertions.assertEquals(404, response.getStatus());
        String actualError = response.getContentAsString();
        Assertions.assertEquals(errorMessage, actualError);
    }

}