package com.mobilebcs.controller.user;


import com.fasterxml.jackson.databind.ObjectMapper;
import com.mobilebcs.ServerApp;
import com.mobilebcs.controller.ControllerTestCaller;
import com.mobilebcs.domain.UserCreatorService;
import com.mobilebcs.domain.UserStarterService;
import com.mobilebcs.domain.UserNonexistentException;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.Captor;
import org.mockito.Mockito;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

@AutoConfigureMockMvc
@ActiveProfiles({"test"})
@SpringBootTest(classes = ServerApp.class)
class UserControllerTest  {


    private ControllerTestCaller controllerTestCaller;
    @MockBean
    private UserCreatorService userCreatorService;
    @MockBean
    private UserStarterService startUserSession;


    @Autowired
    private MockMvc mockMvc;
    @Captor
    private ArgumentCaptor<User> userArgumentCaptor;
    private ObjectMapper objectMapper;

    @BeforeEach
    public void init(){
        objectMapper = new ObjectMapper();
        controllerTestCaller=new ControllerTestCaller(mockMvc, objectMapper);
    }


    @Test
    public void testCreateUser() throws Exception {
        Mockito.doNothing().when(userCreatorService).create(userArgumentCaptor.capture());
        String name = "Pedro";
        MockHttpServletResponse response = controllerTestCaller.post("/user", new User(name));

        Assertions.assertEquals(201,response.getStatus());
        Assertions.assertNotNull(userArgumentCaptor.getValue());
        Assertions.assertEquals(name,userArgumentCaptor.getValue().getCalificatorUser());

    }

    @Test
    public void testCreateUserThatFailed() throws Exception {
        Mockito.doThrow(new RuntimeException("Hubo un error en la creación del usuario")).when(userCreatorService).create(userArgumentCaptor.capture());
        String name = "Pedro";
        MockHttpServletResponse response = controllerTestCaller.post("/user", new User(name));

        Assertions.assertEquals(500,response.getStatus());

    }

    @Test
    public void testStarUserSession() throws Exception {

        String name = "Pedro";
        Mockito.when(startUserSession.startUserSession(Mockito.eq(name))).thenReturn(new User(name));
        MockHttpServletResponse response = controllerTestCaller.getResponse("/user/{name}", name);

        Assertions.assertEquals(200,response.getStatus());
        User user = objectMapper
                .readValue(response.getContentAsByteArray(), User.class);
        Assertions.assertNotNull(user);
        Assertions.assertEquals(name,user.getCalificatorUser());
    }


    @Test
    public void testStartUserSessionWithError() throws Exception {

        String name = "Pedro";
        String errorMessage = "Error buscando usuario";
        Mockito.when(startUserSession.startUserSession(Mockito.eq(name))).thenThrow(new RuntimeException(errorMessage));
        MockHttpServletResponse response = controllerTestCaller.getResponse("/user/{name}", name);

        Assertions.assertEquals(500,response.getStatus());
        String actualError = response.getContentAsString();
        Assertions.assertEquals(errorMessage,actualError);

    }

    @Test
    public void testStartUserSessionThatNotExist() throws Exception {
        String name = "Pedro";
        String errorMessage = "Usuario con nombre " + name + " no existe";
        Mockito.when(startUserSession.startUserSession(Mockito.eq(name))).thenThrow(new UserNonexistentException(errorMessage));
        MockHttpServletResponse response = controllerTestCaller.getResponse("/user/{name}", name);

        Assertions.assertEquals(404,response.getStatus());
        String actualError = response.getContentAsString();
        Assertions.assertEquals(errorMessage,actualError);
    }

}