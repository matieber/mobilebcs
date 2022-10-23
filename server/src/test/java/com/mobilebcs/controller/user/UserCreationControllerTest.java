package com.mobilebcs.controller.user;


import com.fasterxml.jackson.databind.ObjectMapper;
import com.mobilebcs.controller.ControllerTestCaller;
import com.mobilebcs.domain.exception.InvalidRequestExeption;
import com.mobilebcs.domain.exception.UserNonexistentException;
import com.mobilebcs.domain.user.User;
import com.mobilebcs.domain.user.UserCreatorService;
import com.mobilebcs.domain.user.UserQualificationSessionService;
import com.mobilebcs.domain.user.UserRepository;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Captor;
import org.mockito.Mockito;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.test.context.junit.jupiter.SpringExtension;
import org.springframework.test.web.servlet.MockMvc;


@ExtendWith(SpringExtension.class)
@WebMvcTest(controllers = UserController.class)
class UserCreationControllerTest {


    public static final String LOCATION_CODE = "DEFAULT";
    private ControllerTestCaller controllerTestCaller;
    @MockBean
    private UserCreatorService userCreatorService;
    @MockBean
    private UserQualificationSessionService startUserSession;


    @Autowired
    private MockMvc mockMvc;
    @Captor
    private ArgumentCaptor<UserRequest> userArgumentCaptor;
    private ObjectMapper objectMapper;

    @BeforeEach
    public void init(){
        objectMapper = new ObjectMapper();
        controllerTestCaller=new ControllerTestCaller(mockMvc, objectMapper);
    }


    @Test
    public void testCreateUser() throws Exception, InvalidRequestExeption {
        Mockito.doNothing().when(userCreatorService).create(userArgumentCaptor.capture());
        String name = "Pedro";
        MockHttpServletResponse response = controllerTestCaller.post("/user", new User(name,UserType.QUALIFIER));

        Assertions.assertEquals(201,response.getStatus());
        Assertions.assertNotNull(userArgumentCaptor.getValue());
        Assertions.assertEquals(name,userArgumentCaptor.getValue().getUsername());

    }

    @Test
    public void testCreateUserThatFailed() throws Exception, InvalidRequestExeption {
        Mockito.doThrow(new RuntimeException("Hubo un error en la creación del usuario")).when(userCreatorService).create(userArgumentCaptor.capture());
        String name = "Pedro";
        MockHttpServletResponse response = controllerTestCaller.post("/user", new User(name,UserType.QUALIFIER));

        Assertions.assertEquals(500,response.getStatus());

    }



}