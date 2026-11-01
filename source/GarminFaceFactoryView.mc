import Toybox.ActivityMonitor;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

// Apex One / Orbit: static visual foundation for Venu 2.
// Demo values only; live activity/sensor data comes in a later phase.
class GarminFaceFactoryView extends WatchUi.WatchFace {
    const BLACK = 0x000000;
    const WHITE = 0xF4F1E8;
    const MUTED = 0xBFC5CC;
    const GOLD = 0xE5A84B;
    const CYAN = 0x55D6CF;
    const TRACK = 0x101417;

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
        var timeText = Lang.format("$1$:$2$", [
            hour.format("%02d"),
            clock.min.format("%02d")
        ]);

        // Fixed demo data: 8,420 of a 10,000-step sample goal, 86% battery.
        // Ring percentages are derived from these displayed sample values.
        var steps = 8420;
        var stepGoal = 10000;
        var battery = 86;
        var heart = 72;

        // The outer ring is steps / goal; the inner ring is battery / 100.
        // No arbitrary or decorative percentages.
        var scale = w / 416.0;
        var outerRadius = (169 * scale).toNumber();
        var innerRadius = (153 * scale).toNumber();
        drawTrack(dc, cx, cy, outerRadius, 2);
        drawTrack(dc, cx, cy, innerRadius, 2);

        drawProgress(dc, cx, cy, outerRadius, 7, steps.toFloat() / stepGoal, GOLD);
        drawProgress(dc, cx, cy, innerRadius, 6, battery.toFloat() / 100.0, CYAN);

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

        // Give the steps value, its label, and bottom metrics separate rows.
        dc.setColor(GOLD, Graphics.COLOR_TRANSPARENT);
        var stepText = "8,420";
        dc.drawText(cx, (235 * h / 416), Graphics.FONT_MEDIUM,
            stepText, Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(MUTED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, (269 * h / 416), Graphics.FONT_XTINY,
            "STEPS", Graphics.TEXT_JUSTIFY_CENTER);

        // Wide two-column spacing keeps the bottom metrics off the ring edges.
        var heartText = "72";
        var batteryText = "86%";

        dc.setColor(MUTED, Graphics.COLOR_TRANSPARENT);
        dc.drawText((132 * w / 416), (304 * h / 416), Graphics.FONT_XTINY,
            "HR", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText((284 * w / 416), (304 * h / 416), Graphics.FONT_XTINY,
            "BAT", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText((145 * w / 416), (325 * h / 416), Graphics.FONT_SMALL,
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

    function onHide() {
    }

}
