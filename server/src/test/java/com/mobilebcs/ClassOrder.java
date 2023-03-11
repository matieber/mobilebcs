package com.mobilebcs;

import org.junit.jupiter.api.ClassDescriptor;
import org.junit.jupiter.api.ClassOrderer;
import org.junit.jupiter.api.ClassOrdererContext;
import org.springframework.boot.test.context.SpringBootTest;

import java.util.Comparator;

//junit.jupiter.testclass.order.default=foo.MyOrderer
public class ClassOrder implements ClassOrderer {
    @Override
    public void orderClasses(ClassOrdererContext classOrdererContext) {
        classOrdererContext.getClassDescriptors().sort(Comparator.comparingInt(ClassOrder::getOrder));
    }

    private static int getOrder(ClassDescriptor classDescriptor) {
        if(classDescriptor.getTestClass().getName().equals(QualificationWithImageAfterRestartITCase.class.getName())){
            return 2;
        }else{
            return 1;
        }
    }
}
