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
        // Precision Luxury background is a compact indexed-color resource.
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

        // Textured emerald graphite is active-mode only; frozen AOD stays black.
        dc.drawBitmap(0, 0, WatchUi.loadResource(Rez.Drawables.PrecisionBackground));

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

        // Precision Luxury: spacious clock and a single icon-led metric row.
        // Keep the numerals inside the inner progress ring.
        dc.setColor(GOLD, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawLine(cx - 8, (88 * h / 416), cx, (79 * h / 416));
        dc.drawLine(cx, (79 * h / 416), cx + 8, (88 * h / 416));
        dc.drawLine(cx - 3, (88 * h / 416), cx + 3, (82 * h / 416));

        dc.setColor(WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, (105 * h / 416), Graphics.FONT_SMALL,
            dateText, Graphics.TEXT_JUSTIFY_CENTER);
        // Custom engraved serif numerals are the signature visual element.
        // Native vector strokes avoid font-file compatibility and bitmap overhead.
        drawLuxuryTime(dc, cx, (166 * h / 416), timeText);

        // Fine horizontal separator; restrained decoration, not a metric ring.
        var dividerY = (252 * h / 416);
        dc.setPenWidth(1);
        dc.setColor(GOLD, Graphics.COLOR_TRANSPARENT);
        dc.drawLine((99 * w / 416), dividerY, (190 * w / 416), dividerY);
        dc.drawLine((226 * w / 416), dividerY, (317 * w / 416), dividerY);
        dc.drawLine(cx - 6, dividerY, cx, dividerY - 7);
        dc.drawLine(cx, dividerY - 7, cx + 6, dividerY);

        var heartText = "--";
        if (heart != null) {
            heartText = heart.toString();
        }
        var stepText = "--";
        if (steps != null && steps >= 0) {
            stepText = formatSteps(steps);
        }

        // Icon-led two-column metrics. Icons are intentionally separated
        // from numbers and from the central gold hairline.
        var metricY = (286 * h / 416);
        dc.setColor(GOLD, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        // Small precision heart: two round lobes and a clear tapered tip.
        dc.drawArc(119, metricY + 6, 7, Graphics.ARC_COUNTER_CLOCKWISE, 0, 180);
        dc.drawArc(133, metricY + 6, 7, Graphics.ARC_COUNTER_CLOCKWISE, 0, 180);
        dc.drawLine(112, metricY + 6, 126, metricY + 22);
        dc.drawLine(140, metricY + 6, 126, metricY + 22);
        // Footprints: each has a heel, offset sole, and distinct toe marks.
        dc.fillEllipse(231, metricY + 7, 6, 12);
        dc.fillCircle(237, metricY + 4, 2);
        dc.fillCircle(240, metricY + 7, 1);
        dc.fillEllipse(245, metricY + 15, 6, 12);
        dc.fillCircle(251, metricY + 12, 2);
        dc.fillCircle(254, metricY + 15, 1);

        dc.setColor(WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(169, metricY - 1, Graphics.FONT_TINY,
            heartText, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(293, metricY - 1, Graphics.FONT_TINY,
            stepText, Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(GOLD, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawLine(cx, metricY - 5, cx, metricY + 27);

    }

    // Custom compact Roman-inspired clock, 4 digits plus a colon.
    // Every glyph occupies 34x57 pixels, with fixed-width spacing.
    function drawLuxuryTime(dc, cx, top, timeText) {
        var left = cx - 94;
        dc.setColor(WHITE, Graphics.COLOR_TRANSPARENT);
        for (var i = 0; i < 5; i++) {
            var ch = timeText.substring(i, i + 1);
            if (ch == ":") {
                dc.fillCircle(left + 17, top + 18, 2);
                dc.fillCircle(left + 17, top + 41, 2);
                left += 18;
            } else {
                drawLuxuryDigit(dc, left, top, ch);
                left += 43;
            }
        }
    }

    function luxuryLine(dc, x1, y1, x2, y2) {
        dc.drawLine(x1, y1, x2, y2);
    }

    // Strokes use true curves for rounded digits, with hairline serifs.
    function drawLuxuryDigit(dc, x, y, ch) {
        dc.setPenWidth(2);
        if (ch == "0") {
            dc.drawEllipse(x + 5, y + 1, 26, 55);
            dc.setPenWidth(1);
            luxuryLine(dc, x + 8, y + 49, x + 27, y + 8);
        } else if (ch == "1") {
            luxuryLine(dc, x + 7, y + 11, x + 19, y + 2);
            luxuryLine(dc, x + 19, y + 2, x + 19, y + 55);
            luxuryLine(dc, x + 7, y + 55, x + 31, y + 55);
            dc.setPenWidth(1);
            luxuryLine(dc, x + 14, y + 3, x + 24, y + 3);
        } else if (ch == "2") {
            dc.drawArc(x + 18, y + 15, 14, Graphics.ARC_CLOCKWISE, 0, 180);
            luxuryLine(dc, x + 32, y + 15, x + 5, y + 55);
            luxuryLine(dc, x + 5, y + 55, x + 32, y + 55);
            dc.setPenWidth(1);
            luxuryLine(dc, x + 3, y + 47, x + 3, y + 55);
        } else if (ch == "3") {
            dc.drawArc(x + 15, y + 15, 13, Graphics.ARC_CLOCKWISE, 270, 90);
            dc.drawArc(x + 15, y + 41, 13, Graphics.ARC_CLOCKWISE, 270, 90);
            luxuryLine(dc, x + 15, y + 28, x + 26, y + 28);
        } else if (ch == "4") {
            luxuryLine(dc, x + 26, y + 2, x + 26, y + 55);
            luxuryLine(dc, x + 5, y + 35, x + 33, y + 35);
            luxuryLine(dc, x + 5, y + 35, x + 24, y + 2);
            dc.setPenWidth(1);
            luxuryLine(dc, x + 19, y + 55, x + 32, y + 55);
        } else if (ch == "5") {
            luxuryLine(dc, x + 30, y + 3, x + 8, y + 3);
            luxuryLine(dc, x + 8, y + 3, x + 7, y + 27);
            luxuryLine(dc, x + 7, y + 27, x + 24, y + 27);
            dc.drawArc(x + 17, y + 41, 14, Graphics.ARC_CLOCKWISE, 270, 90);
        } else if (ch == "6") {
            dc.drawEllipse(x + 5, y + 27, 27, 29);
            luxuryLine(dc, x + 6, y + 38, x + 23, y + 2);
            dc.setPenWidth(1);
            luxuryLine(dc, x + 20, y + 2, x + 29, y + 2);
        } else if (ch == "7") {
            luxuryLine(dc, x + 4, y + 3, x + 32, y + 3);
            luxuryLine(dc, x + 32, y + 3, x + 12, y + 55);
            dc.setPenWidth(1);
            luxuryLine(dc, x + 4, y + 3, x + 4, y + 12);
        } else if (ch == "8") {
            dc.drawEllipse(x + 8, y + 2, 21, 26);
            dc.drawEllipse(x + 4, y + 27, 29, 29);
        } else if (ch == "9") {
            dc.drawEllipse(x + 5, y + 2, 27, 29);
            luxuryLine(dc, x + 31, y + 18, x + 12, y + 55);
            dc.setPenWidth(1);
            luxuryLine(dc, x + 7, y + 55, x + 17, y + 55);
        }
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
        dc.drawArc(cx, cy, radius, Graphics.ARC_CLOCKWISE, 90, 90 + sweep);
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
