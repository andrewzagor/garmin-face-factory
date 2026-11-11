import Toybox.ActivityMonitor;
import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;
import Toybox.Weather;

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
    var _background = null;
    var _heartIcon = null;
    var _stepsIcon = null;
    var _luxuryFont = null;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc) {
        // Cache static resources once; loading every screen update costs power.
        _background = WatchUi.loadResource(Rez.Drawables.PrecisionBackground);
        _heartIcon = WatchUi.loadResource(Rez.Drawables.HeartIcon);
        _stepsIcon = WatchUi.loadResource(Rez.Drawables.StepsIcon);
        try {
            _luxuryFont = WatchUi.loadResource(Rez.Fonts.PrecisionTime);
        } catch (ex) {
            // If a custom font resource is unavailable, native time survives.
            _luxuryFont = null;
        }
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

        // Active-only mineral dial. Never draw it behind the frozen AOD.
        if (_background != null) {
            dc.drawBitmap(0, 0, _background);
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

        // Wider concentric rings frame the screen, without touching its edge:
        // outer = steps / goal; inner = remaining battery / 100.
        var scale = w / 416.0;
        var outerRadius = (190 * scale).toNumber();
        var innerRadius = (172 * scale).toNumber();
        drawTrack(dc, cx, cy, outerRadius, 3);
        drawTrack(dc, cx, cy, innerRadius, 2);

        if (steps != null && steps >= 0 && stepGoal != null && stepGoal > 0) {
            drawProgress(dc, cx, cy, outerRadius, 9,
                steps.toFloat() / stepGoal.toFloat(), stepAccent);
        }
        if (battery != null) {
            drawProgress(dc, cx, cy, innerRadius, 7,
                battery.toFloat() / 100.0, batteryAccent);
        }

        // Built-in Garmin weather cache. If missing/stale, use a
        // truthful placeholder; never show invented or old temperatures.
        var temperature = null;
        var weatherCondition = null;
        try {
            var conditions = Weather.getCurrentConditions();
            if (conditions != null && conditions.temperature != null &&
                conditions.observationTime != null) {
                var age = Time.now().subtract(conditions.observationTime).value();
                if (age >= 0 && age <= 10800 &&
                    conditions.temperature >= -70 && conditions.temperature <= 60) {
                    temperature = conditions.temperature.toNumber();
                    weatherCondition = conditions.condition;
                }
            }
        } catch (weatherError) {
            temperature = null;
        }

        // Garmin reports active notifications on the device; show a badge
        // only when at least one is present (zero stays invisible).
        var notificationCount = 0;
        try {
            var deviceSettings = System.getDeviceSettings();
            if (deviceSettings != null && deviceSettings.notificationCount != null &&
                deviceSettings.notificationCount > 0) {
                notificationCount = deviceSettings.notificationCount;
            }
        } catch (notificationError) {
            notificationCount = 0;
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
        if (notificationCount > 0) {
            drawNotificationBadge(dc, notificationCount);
        }
        // Display high-contrast luxury serif glyphs, with reliable native
        // numerals as an immediate fallback if a graphic resource fails.
        drawPrecisionTime(dc, cx, (155 * h / 416), timeText);

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

        // Precision Luxury v2: three compact values with deliberate spacing.
        // Every reading remains inside the inner ring for up to 99,999 steps.
        var metricY = (286 * h / 416);
        if (_heartIcon != null) {
            dc.drawBitmap((95 * w / 416), metricY - 3, _heartIcon);
        }
        if (_stepsIcon != null) {
            dc.drawBitmap((254 * w / 416), metricY - 4, _stepsIcon);
        }

        dc.setColor(WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText((153 * w / 416), metricY - 2, Graphics.FONT_TINY,
            heartText, Graphics.TEXT_JUSTIFY_CENTER);

        drawWeatherMetric(dc, cx, metricY, temperature, weatherCondition);

        var stepFont = Graphics.FONT_TINY;
        if (steps != null && steps >= 10000) {
            stepFont = Graphics.FONT_XTINY;
        }
        dc.setColor(WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText((312 * w / 416), metricY - 2, stepFont,
            stepText, Graphics.TEXT_JUSTIFY_CENTER);

        // Do not draw separators between tight columns: the three
        // icon/value groups provide their own visual rhythm.

    }

    // Small notification marker: no badge at zero; 9+ is the visual cap.
    // notificationCount means active device notifications (Garmin API).
    function drawNotificationBadge(dc, count) {
        var x = 293;
        var y = 85;
        dc.setColor(GOLD, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        // Bell silhouette and clapper, all native vector primitives.
        dc.drawLine(x - 5, y + 4, x - 5, y - 3);
        dc.drawLine(x - 5, y - 3, x - 3, y - 6);
        dc.drawLine(x - 3, y - 6, x + 3, y - 6);
        dc.drawLine(x + 3, y - 6, x + 5, y - 3);
        dc.drawLine(x + 5, y - 3, x + 5, y + 4);
        dc.drawLine(x - 8, y + 5, x + 8, y + 5);
        dc.fillCircle(x, y + 8, 2);
        dc.setColor(WHITE, Graphics.COLOR_TRANSPARENT);
        var label = count > 9 ? "9+" : count.toString();
        dc.drawText(314, 76, Graphics.FONT_XTINY, label,
            Graphics.TEXT_JUSTIFY_CENTER);
    }

    // Weather is sourced from the native Garmin weather cache (Celsius).
    // An unavailable reading is shown as --, never as an assumed temperature.
    function drawWeatherMetric(dc, cx, y, temperature, condition) {
        var iconX = cx - 26;
        var iconY = y + 10;
        dc.setColor(GOLD, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        if (temperature == null) {
            // A subdued sun outline is a field glyph, not a condition claim.
            dc.drawCircle(iconX, iconY, 7);
        } else if (condition == Weather.CONDITION_CLEAR ||
                   condition == Weather.CONDITION_MOSTLY_CLEAR ||
                   condition == Weather.CONDITION_PARTLY_CLEAR ||
                   condition == Weather.CONDITION_FAIR) {
            dc.drawCircle(iconX, iconY, 5);
            dc.drawLine(iconX - 9, iconY, iconX - 7, iconY);
            dc.drawLine(iconX + 7, iconY, iconX + 9, iconY);
            dc.drawLine(iconX, iconY - 9, iconX, iconY - 7);
            dc.drawLine(iconX, iconY + 7, iconX, iconY + 9);
        } else {
            // Cloud symbol for other conditions: rain and snow get
            // small distinctive falling marks.
            dc.drawArc(iconX - 4, iconY, 5, Graphics.ARC_CLOCKWISE, 30, 170);
            dc.drawArc(iconX + 4, iconY - 1, 6, Graphics.ARC_CLOCKWISE, 15, 180);
            dc.drawLine(iconX - 11, iconY + 5, iconX + 11, iconY + 5);
            if (condition == Weather.CONDITION_RAIN ||
                condition == Weather.CONDITION_LIGHT_RAIN ||
                condition == Weather.CONDITION_HEAVY_RAIN ||
                condition == Weather.CONDITION_SHOWERS ||
                condition == Weather.CONDITION_DRIZZLE) {
                dc.drawLine(iconX - 3, iconY + 8, iconX - 5, iconY + 12);
                dc.drawLine(iconX + 5, iconY + 8, iconX + 3, iconY + 12);
            } else if (condition == Weather.CONDITION_SNOW ||
                       condition == Weather.CONDITION_LIGHT_SNOW ||
                       condition == Weather.CONDITION_HEAVY_SNOW) {
                dc.fillCircle(iconX - 4, iconY + 10, 1);
                dc.fillCircle(iconX + 5, iconY + 10, 1);
            }
        }

        dc.setColor(WHITE, Graphics.COLOR_TRANSPARENT);
        if (temperature != null) {
            var tempText = temperature.toString();
            dc.drawText(cx + 12, y - 2, Graphics.FONT_TINY,
                tempText, Graphics.TEXT_JUSTIFY_CENTER);
            // Native circle instead of a font-dependent degree glyph.
            dc.setPenWidth(1);
            var degreeX = cx + (tempText.length() >= 3 ? 35 : 28);
            dc.drawCircle(degreeX, y + 3, 2);
        } else {
            dc.drawText(cx + 15, y - 2, Graphics.FONT_TINY,
                "--", Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    // Font resource is a verified raster BMFont atlas instead of SVG paths.
    // The reliable Garmin clock remains the fallback if anything fails.
    function drawPrecisionTime(dc, cx, top, timeText) {
        if (_luxuryFont != null) {
            try {
                dc.setColor(WHITE, Graphics.COLOR_TRANSPARENT);
                dc.drawText(cx, top, _luxuryFont, timeText,
                    Graphics.TEXT_JUSTIFY_CENTER);
                return;
            } catch (ex) {
                // Keep time visible even when a custom font cannot render.
            }
        }
        dc.setColor(WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, (147 * dc.getHeight() / 416),
            Graphics.FONT_NUMBER_MEDIUM, timeText,
            Graphics.TEXT_JUSTIFY_CENTER);
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
