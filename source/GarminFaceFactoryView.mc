import Toybox.ActivityMonitor;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

// Apex One / Orbit: one carefully composed, data-driven Venu 2 watch face.
class GarminFaceFactoryView extends WatchUi.WatchFace {
    const BLACK = 0x000000;
    const WHITE = 0xF4F1E8;
    const MUTED = 0xBFC5CC;
    const GOLD = 0xE5A84B;
    const CYAN = 0x55D6CF;
    const TRACK = 0x20252A;

    var _lowPower = false;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc) {
        // Native drawing only; no bitmap assets or extra layout resources.
    }

    function onShow() {
    }

    function onUpdate(dc) {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var cx = w / 2;
        var cy = h / 2;

        dc.setColor(BLACK, BLACK);
        dc.clear();

        var clock = System.getClockTime();
        var hour = clock.hour;
        var is24Hour = true;
        var settings = System.getDeviceSettings();
        if (settings != null) {
            is24Hour = settings.is24Hour;
        }
        if (!is24Hour) {
            hour = hour % 12;
            if (hour == 0) {
                hour = 12;
            }
        }
        var timeText = Lang.format("$1$:$2$", [
            hour.format("%02d"),
            clock.min.format("%02d")
        ]);

        // Low-power presentation intentionally uses fewer illuminated pixels.
        if (_lowPower) {
            dc.setColor(MUTED, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, cy - 32, Graphics.FONT_NUMBER_MEDIUM,
                timeText, Graphics.TEXT_JUSTIFY_CENTER);
            return;
        }

        var activity = ActivityMonitor.getInfo();
        var steps = null;
        var goal = null;
        var heart = null;
        if (activity != null) {
            steps = activity.steps;
            goal = activity.stepGoal;
            heart = activity.currentHeartRate;
        }

        var battery = null;
        var stats = System.getSystemStats();
        if (stats != null && stats.battery != null) {
            battery = stats.battery.toNumber();
            if (battery < 0 || battery > 100) {
                battery = null;
            }
        }

        // The outer ring is steps / goal; the inner ring is battery / 100.
        // No arbitrary or decorative percentages.
        var scale = w / 416.0;
        var outerRadius = (169 * scale).toNumber();
        var innerRadius = (153 * scale).toNumber();
        drawTrack(dc, cx, cy, outerRadius, 7);
        drawTrack(dc, cx, cy, innerRadius, 6);

        if (steps != null && goal != null && steps >= 0 && goal > 0) {
            drawProgress(dc, cx, cy, outerRadius, 7, steps.toFloat() / goal, GOLD);
        }
        if (battery != null) {
            drawProgress(dc, cx, cy, innerRadius, 6, battery.toFloat() / 100.0, CYAN);
        }

        var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var weekdays = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
        var months = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
                      "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];
        var weekday = "--";
        var month = "---";
        if (today.day_of_week >= 1 && today.day_of_week <= 7) {
            weekday = weekdays[today.day_of_week - 1];
        }
        if (today.month >= 1 && today.month <= 12) {
            month = months[today.month - 1];
        }
        var dateText = weekday + " " + today.day.format("%02d") + " " + month;

        // Text anchors are deliberately central and clear of both rings.
        dc.setColor(MUTED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, (112 * h / 416), Graphics.FONT_SMALL,
            dateText, Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, (149 * h / 416), Graphics.FONT_NUMBER_MEDIUM,
            timeText, Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(GOLD, Graphics.COLOR_TRANSPARENT);
        var stepText = "--";
        if (steps != null && steps >= 0) {
            stepText = groupedNumber(steps);
        }
        dc.drawText(cx, (245 * h / 416), Graphics.FONT_MEDIUM,
            stepText, Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(MUTED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, (280 * h / 416), Graphics.FONT_XTINY,
            "STEPS", Graphics.TEXT_JUSTIFY_CENTER);

        var heartText = "--";
        if (heart != null && heart > 0) {
            heartText = heart.toString();
        }
        var batteryText = "--";
        if (battery != null) {
            batteryText = battery.toString() + "%";
        }

        dc.setColor(MUTED, Graphics.COLOR_TRANSPARENT);
        dc.drawText((145 * w / 416), (304 * h / 416), Graphics.FONT_XTINY,
            "HR", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText((270 * w / 416), (304 * h / 416), Graphics.FONT_XTINY,
            "POWER", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText((145 * w / 416), (320 * h / 416), Graphics.FONT_SMALL,
            heartText, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText((270 * w / 416), (320 * h / 416), Graphics.FONT_SMALL,
            batteryText, Graphics.TEXT_JUSTIFY_CENTER);
    }

    // Draw only actual progress; native arcs avoid bitmap memory overhead.
    function drawProgress(dc, cx, cy, radius, stroke, fraction, color) {
        if (fraction < 0) {
            fraction = 0;
        } else if (fraction > 1) {
            fraction = 1;
        }
        if (fraction <= 0) {
            return;
        }
        dc.setPenWidth(stroke);
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        var sweep = (fraction * 360).toNumber();
        dc.drawArc(cx, cy, radius, Graphics.ARC_CLOCKWISE, 90, 90 - sweep);
    }

    function drawTrack(dc, cx, cy, radius, stroke) {
        dc.setPenWidth(stroke);
        dc.setColor(TRACK, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(cx, cy, radius);
    }

    function groupedNumber(value) {
        var digits = value.toString();
        var result = "";
        var count = 0;
        for (var i = digits.length() - 1; i >= 0; i--) {
            if (count > 0 && count % 3 == 0) {
                result = "," + result;
            }
            result = digits.substring(i, i + 1) + result;
            count += 1;
        }
        return result;
    }

    function onHide() {
    }

    function onEnterSleep() {
        _lowPower = true;
    }

    function onExitSleep() {
        _lowPower = false;
    }
}
