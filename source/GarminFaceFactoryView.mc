import Toybox.ActivityMonitor;
import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

// Apex One / Orbit: live Garmin metrics with the accepted Venu 2 layout.
class GarminFaceFactoryView extends WatchUi.WatchFace {
    const BLACK = 0x000000;
    const WHITE = 0xF4F1E8;
    const MUTED = 0xBFC5CC;
    const GOLD = 0xE5A84B;
    const CYAN = 0x55D6CF;
    const TRACK = 0x101417;
    // Active-display theme palettes; the approved AOD colors stay fixed.
    const TITANIUM_SILVER = 0xD4DCE5;
    const TITANIUM_ICE = 0x89DDF2;
    const ELECTRIC_BLUE = 0x378BFF;
    const ELECTRIC_VIOLET = 0xBB82FF;
    const AOD_TEXT = 0x777B7D;
    const AOD_GOLD = 0x4D3920;
    const AOD_CYAN = 0x1B4442;

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
        var timeText = Lang.format("$1$:$2$", [
            hour.format("%02d"),
            clock.min.format("%02d")
        ]);

        // AMOLED AOD: only a small, subdued time readout. No rings or
        // metrics; skip all sensor reads and active-mode drawing.
        if (_lowPower) {
            drawAlwaysOn(dc, cx, cy, timeText, clock.min);
            return;
        }

        // Only the normal display uses the selected Connect IQ app theme.
        // Missing or invalid settings fall back to Orbit Gold.
        var stepAccent = GOLD;
        var batteryAccent = CYAN;
        var selectedTheme = Application.Properties.getValue("ColorTheme");
        if (selectedTheme == 1) {
            stepAccent = TITANIUM_SILVER;
            batteryAccent = TITANIUM_ICE;
        } else if (selectedTheme == 2) {
            stepAccent = ELECTRIC_BLUE;
            batteryAccent = ELECTRIC_VIOLET;
        }

        // Read current daily activity and the user's actual step goal.
        // All activity fields are nullable on supported Garmin devices.
        var steps = null;
        var stepGoal = null;
        var activity = ActivityMonitor.getInfo();
        if (activity != null) {
            steps = activity.steps;
            stepGoal = activity.stepGoal;
        }

        // Battery is reported by SystemStats, not a fabricated goal.
        var battery = null;
        var stats = System.getSystemStats();
        if (stats != null && stats.battery != null) {
            var reportedBattery = stats.battery.toNumber();
            if (reportedBattery >= 0 && reportedBattery <= 100) {
                battery = reportedBattery;
            }
        }

        // Watch-face-safe HR history API (available since Connect IQ 1.2.1).
        // Only show a recent, valid sample; never retain an old reading as live.
        var heart = null;
        var hrHistory = ActivityMonitor.getHeartRateHistory(1, true);
        if (hrHistory != null) {
            var hrSample = hrHistory.next();
            if (hrSample != null && hrSample.heartRate != null &&
                hrSample.heartRate != ActivityMonitor.INVALID_HR_SAMPLE &&
                hrSample.heartRate > 0 && hrSample.when != null) {
                var sampleAge = Time.now().subtract(hrSample.when).value();
                if (sampleAge >= 0 && sampleAge <= 300) {
                    heart = hrSample.heartRate;
                }
            }
        }

        // The outer ring is steps / goal; the inner ring is battery / 100.
        // No arbitrary or decorative percentages.
        var scale = w / 416.0;
        var outerRadius = (169 * scale).toNumber();
        var innerRadius = (153 * scale).toNumber();
        drawTrack(dc, cx, cy, outerRadius, 2);
        drawTrack(dc, cx, cy, innerRadius, 2);

        if (steps != null && steps >= 0 && stepGoal != null && stepGoal > 0) {
            drawProgress(dc, cx, cy, outerRadius, 7,
                steps.toFloat() / stepGoal.toFloat(), stepAccent);
        }
        if (battery != null) {
            drawProgress(dc, cx, cy, innerRadius, 6,
                battery.toFloat() / 100.0, batteryAccent);
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

        // Compact lower typography: keep 40,000 and both metric columns inside
        // the inner ring, with distinct steps, label, and metric rows.
        dc.setColor(stepAccent, Graphics.COLOR_TRANSPARENT);
        var stepText = "--";
        if (steps != null && steps >= 0) {
            stepText = formatSteps(steps);
        }
        dc.drawText(cx, (224 * h / 416), Graphics.FONT_SMALL,
            stepText, Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(MUTED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, (257 * h / 416), Graphics.FONT_TINY,
            "STEPS", Graphics.TEXT_JUSTIFY_CENTER);

        // Bottom values sit higher and nearer the center, inside the inner ring.
        // Both labels share the same x as their value (including 100% BAT).
        var heartText = "--";
        if (heart != null) {
            heartText = heart.toString();
        }
        var batteryText = "--";
        if (battery != null) {
            batteryText = battery.toString() + "%";
        }

        dc.setColor(MUTED, Graphics.COLOR_TRANSPARENT);
        dc.drawText((155 * w / 416), (283 * h / 416), Graphics.FONT_TINY,
            "HR", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText((261 * w / 416), (283 * h / 416), Graphics.FONT_TINY,
            "BAT", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText((155 * w / 416), (304 * h / 416), Graphics.FONT_TINY,
            heartText, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText((261 * w / 416), (304 * h / 416), Graphics.FONT_TINY,
            batteryText, Graphics.TEXT_JUSTIFY_CENTER);
    }

    // Small, gray clock and two restrained Orbit markers on true black.
    // A 5x5 offset cycle shifts the glyphs
    // by up to four pixels every minute to reduce persistent pixel wear.
    // The platform owns the low-power once-per-minute refresh cadence.
    function drawAlwaysOn(dc, cx, cy, timeText, minute) {
        var phase = minute % 25;
        var dx = (phase % 5) - 2;
        var dy = (phase / 5).toNumber() - 2;
        dc.setColor(AOD_TEXT, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx + dx, cy - 13 + dy, Graphics.FONT_MEDIUM,
            timeText, Graphics.TEXT_JUSTIFY_CENTER);

        // Orbit fingerprint: two very short, one-pixel arcs, not progress
        // indicators. Move with the clock's burn-in mitigation offset.
        dc.setPenWidth(1);
        dc.setColor(AOD_GOLD, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(cx + dx, cy + dy, 95, Graphics.ARC_CLOCKWISE, 96, 84);
        dc.setColor(AOD_CYAN, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(cx + dx, cy + dy, 95, Graphics.ARC_CLOCKWISE, 276, 264);
    }

    function onEnterSleep() {
        _lowPower = true;
        WatchUi.requestUpdate();
    }

    function onExitSleep() {
        _lowPower = false;
        WatchUi.requestUpdate();
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

    // Group steps without changing the accepted number position or font.
    function formatSteps(steps) {
        var digits = steps.toString();
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

}
