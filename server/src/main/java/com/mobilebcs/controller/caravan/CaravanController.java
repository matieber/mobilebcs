package com.mobilebcs.controller.caravan;

import com.mobilebcs.domain.caravan.CaravanService;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.util.CollectionUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/caravan")
public class CaravanController {

    private CaravanService caravanService;

    public CaravanController(CaravanService caravanService) {
        this.caravanService = caravanService;
    }

    @GetMapping(value = "/{identification}",produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<CaravanInfoResponse> lookup(@PathVariable("identification") String identification){
        CaravanInfoResponse caravanInfoResponse=caravanService.lookup(identification);
        if(caravanInfoResponse==null || CollectionUtils.isEmpty(caravanInfoResponse.getList())){
            return ResponseEntity.noContent().build();
        }else{
            return ResponseEntity.ok(caravanInfoResponse);
        }
    }
}
