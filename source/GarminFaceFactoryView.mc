import Toybox.ActivityMonitor;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

class GarminFaceFactoryView extends WatchUi.WatchFace {

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Dc) as Void {
        // The minimalist face is drawn directly in onUpdate.
    }

    function onShow() as Void {
    }

    function onUpdate(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;

        // Black AMOLED background.
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        // Current time in large white digits.
        var clock = System.getClockTime();
        var timeText = Lang.format("$1$:$2$", [
            clock.hour.format("%02d"),
            clock.min.format("%02d")
        ]);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, height * 32 / 100, Graphics.FONT_NUMBER_MEDIUM,
            timeText, Graphics.TEXT_JUSTIFY_CENTER);

        // Date beneath the time (day/month).
        var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var dateText = Lang.format("$1$/$2$", [
            today.day.format("%02d"),
            today.month.format("%02d")
        ]);
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, height * 53 / 100, Graphics.FONT_MEDIUM,
            dateText, Graphics.TEXT_JUSTIFY_CENTER);

        // Battery percentage and daily steps.
        var battery = System.getSystemStats().battery.toNumber();
        var steps = ActivityMonitor.getInfo().steps;
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width * 30 / 100, height * 73 / 100, Graphics.FONT_SMALL,
            "BATTERY", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(width * 3 / 4, height * 73 / 100, Graphics.FONT_SMALL,
            "STEPS", Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 4, height * 81 / 100, Graphics.FONT_MEDIUM,
            battery.toString() + "%", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(width * 3 / 4, height * 81 / 100, Graphics.FONT_MEDIUM,
            steps.toString(), Graphics.TEXT_JUSTIFY_CENTER);
    }

    function onHide() as Void {
    }

    function onExitSleep() as Void {
    }

    function onEnterSleep() as Void {
    }
}
