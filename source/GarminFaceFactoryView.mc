import Toybox.ActivityMonitor;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

// Sport Pulse: a training-dashboard layout with cyan and orange accents.
class GarminFaceFactoryView extends WatchUi.WatchFace {

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Dc) as Void {
        // Draw directly to keep the design independent of XML layout labels.
    }

    function onShow() as Void {
    }

    function onUpdate(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        // Athletic header and short orange speed stripe.
        dc.setColor(0x00FFFF, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, height * 12 / 100, Graphics.FONT_SMALL,
            "SPORT PULSE", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(width * 35 / 100, height * 22 / 100,
            width * 30 / 100, 3);

        // Large central time is the primary readout.
        var clock = System.getClockTime();
        var timeText = Lang.format("$1$:$2$", [
            clock.hour.format("%02d"),
            clock.min.format("%02d")
        ]);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, height * 27 / 100, Graphics.FONT_NUMBER_MEDIUM,
            timeText, Graphics.TEXT_JUSTIFY_CENTER);

        // Wide step counter forms the main sport-focused panel.
        var steps = ActivityMonitor.getInfo().steps;
        dc.setColor(0x00FFFF, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, height * 49 / 100, Graphics.FONT_SMALL,
            "TODAY'S STEPS", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, height * 56 / 100, Graphics.FONT_NUMBER_MEDIUM,
            steps.toString(), Graphics.TEXT_JUSTIFY_CENTER);

        // A horizontal divider separates performance and status data.
        dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(width * 26 / 100, height * 75 / 100,
            width * 48 / 100, 2);

        var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var dateText = Lang.format("$1$/$2$", [
            today.day.format("%02d"),
            today.month.format("%02d")
        ]);
        var battery = System.getSystemStats().battery.toNumber();

        // Compact, safely inset footer for the circular screen.
        dc.setColor(0x00FFFF, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width * 35 / 100, height * 79 / 100, Graphics.FONT_SMALL,
            "DATE", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(width * 65 / 100, height * 79 / 100, Graphics.FONT_SMALL,
            "BAT", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width * 35 / 100, height * 86 / 100, Graphics.FONT_SMALL,
            dateText, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(width * 65 / 100, height * 86 / 100, Graphics.FONT_SMALL,
            battery.toString() + "%", Graphics.TEXT_JUSTIFY_CENTER);
    }

    function onHide() as Void {
    }

    function onExitSleep() as Void {
    }

    function onEnterSleep() as Void {
    }
}
