package io.flutter.calificator.services;

import android.content.ContextWrapper;

import io.flutter.calificator.utils.Logger;


class BenchmarkProgressUpdater extends ProgressUpdater {

    BenchmarkProgressUpdater(ContextWrapper contextWrapper, String updateAction, String endAction, String variant, Logger logger) {
        super(contextWrapper, updateAction, endAction, variant, logger);
    }

    @Override
    String specificUpdateMessage(String msg) {
        return ("Run stage: \n" + msg);
    }
}
