package org.iremia.iremia.ui.home

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Text
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowLeft
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import kotlin.math.roundToInt
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.StrokeJoin
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import org.iremia.iremia.domain.insights.InsightConfidence
import org.iremia.iremia.domain.insights.MotivationInsight
import org.iremia.iremia.utils.localized
import org.iremia.library.SharedRes
import dev.icerock.moko.resources.StringResource

// Home design tokens (from design_handoff_iremia_home). Kept local to the home
// package so the new screen matches the handoff exactly without touching the
// app-wide Material palette.
private object HomeColors {
    val bg = Color(0xFFEDF1F1)
    val card = Color(0xFFFFFFFF)
    val ink = Color(0xFF1A2A2E)
    val inkSoft = Color(0xFF566B71)
    val inkMute = Color(0xFF8B989D)
    val line = Color(0x141A2A2E) // #1A2A2E @ 8%
    val teal = Color(0xFF0E7B8A)
    val tealDeep = Color(0xFF1A7283)
    val tealDeep2 = Color(0xFF0E5965)
    val tealSoft = Color(0xFFD7E9EB)
    val tealSofter = Color(0xFFE7F1F2)
    val onTeal = Color(0xFFEAF6F7)
    val onTealMute = Color(0x9EEAF6F7) // #EAF6F7 @ 62%
    val chartLine = Color(0xFFA9E6E2)
}

/**
 * A single auto-detected pattern card in the "Was dir gut tut" section.
 * Placeholder content for now (allowed by product); the pattern engine can fill
 * these later.
 */
private data class PatternCardData(
    val titleRes: StringResource,
    val metaRes: StringResource,
)

/**
 * Home (Start) screen, rebuilt from design_handoff_iremia_home.
 *
 * The blue [HeroInsightCard] binds to a [MotivationInsight]; a placeholder is used
 * until the motivation algorithm is wired in, so the layout is complete now and
 * the real insight slots in without UI changes.
 */
@Composable
fun HomeScreen(
    modifier: Modifier = Modifier,
    insight: MotivationInsight = MotivationInsight.placeholder,
    gardenTiles: List<org.iremia.iremia.domain.garden.GardenTile> = emptyList(),
    gardenColumns: Int = 5,
    gardenRows: Int = 5,
    onOpenJournal: () -> Unit = {},
) {
    // The trend point tapped on the graph, if any, drives the detail dialog (Block 2).
    var selectedPoint by remember { mutableStateOf<org.iremia.iremia.domain.insights.TrendPoint?>(null) }

    Column(
        modifier = modifier
            .fillMaxSize()
            .background(HomeColors.bg)
            .verticalScroll(rememberScrollState()),
    ) {
        GreetingHeader()
        // Entry point (Block 1.3): garden preview + "make entry" / "view garden".
        // Both lead to the Journal tab, which hosts the capture flow and garden.
        GardenEntryCard(
            tiles = gardenTiles,
            columns = gardenColumns,
            rows = gardenRows,
            onMakeEntry = onOpenJournal,
            onViewGarden = onOpenJournal,
            modifier = Modifier.padding(top = 20.dp, start = 16.dp, end = 16.dp),
        )
        HeroInsightCard(
            insight = insight,
            onPointTap = { selectedPoint = it },
            modifier = Modifier.padding(top = 20.dp, start = 16.dp, end = 16.dp),
        )
        PatternsSection(modifier = Modifier.padding(top = 24.dp, start = 16.dp, end = 16.dp))
        DailyFlashcard(modifier = Modifier.padding(top = 24.dp, start = 16.dp, end = 16.dp))
        Spacer(Modifier.height(24.dp))
    }

    selectedPoint?.let { point ->
        TrendPointDialog(point = point, onDismiss = { selectedPoint = null })
    }
}

/**
 * Detail dialog for a tapped trend point (Block 2). Shows the day, the entry's
 * intensity, and a gentle, never-judgmental note on how it moved the course.
 */
@Composable
private fun TrendPointDialog(
    point: org.iremia.iremia.domain.insights.TrendPoint,
    onDismiss: () -> Unit,
) {
    val context = LocalContext.current
    val dateText = remember(point.createdAt) {
        val dt = java.time.Instant.ofEpochMilli(point.createdAt)
            .atZone(java.time.ZoneId.systemDefault())
        val months = listOf("Jan", "Feb", "Mär", "Apr", "Mai", "Jun", "Jul", "Aug", "Sep", "Okt", "Nov", "Dez")
        "${dt.dayOfMonth}. ${months[dt.monthValue - 1]} ${dt.year}"
    }
    val directionText = when (point.direction) {
        org.iremia.iremia.domain.insights.TrendDirection.CALMER -> localized(SharedRes.strings.trend_detail_calmer)
        org.iremia.iremia.domain.insights.TrendDirection.MORE_INTENSE -> localized(SharedRes.strings.trend_detail_more_intense)
        org.iremia.iremia.domain.insights.TrendDirection.STEADY -> localized(SharedRes.strings.trend_detail_steady)
    }.toString(context)

    androidx.compose.material3.AlertDialog(
        onDismissRequest = onDismiss,
        confirmButton = {
            androidx.compose.material3.TextButton(onClick = onDismiss) {
                Text(localized(SharedRes.strings.nav_close).toString(context), color = HomeColors.teal)
            }
        },
        title = {
            Text(localized(SharedRes.strings.trend_detail_title).toString(context), color = HomeColors.ink, fontWeight = FontWeight.Bold)
        },
        text = {
            Column {
                Text(dateText, fontSize = 13.sp, color = HomeColors.inkMute)
                Spacer(Modifier.height(8.dp))
                if (point.intensity != null) {
                    Text(
                        localized(SharedRes.strings.trend_detail_intensity).toString(context).replace("%1\$d", point.intensity.toString()),
                        fontSize = 15.sp,
                        color = HomeColors.ink,
                    )
                } else {
                    Text(localized(SharedRes.strings.trend_detail_journal).toString(context), fontSize = 15.sp, color = HomeColors.ink)
                }
                Spacer(Modifier.height(8.dp))
                Text(directionText, fontSize = 14.sp, color = HomeColors.inkSoft)
            }
        },
        containerColor = HomeColors.card,
    )
}

/**
 * Home entry point: the real garden preview (this month's live tiles) and the two
 * primary actions. The full garden and the capture flow live on the Journal tab.
 */
@Composable
private fun GardenEntryCard(
    tiles: List<org.iremia.iremia.domain.garden.GardenTile>,
    columns: Int,
    rows: Int,
    onMakeEntry: () -> Unit,
    onViewGarden: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val context = LocalContext.current
    Column(
        modifier = modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(20.dp))
            .background(HomeColors.card)
            .border(1.dp, HomeColors.line, RoundedCornerShape(20.dp))
            .padding(16.dp),
    ) {
        Text(
            text = localized(SharedRes.strings.home_garden_preview_title).toString(context),
            fontSize = 11.sp,
            fontWeight = FontWeight.Bold,
            letterSpacing = 1.1.sp,
            color = HomeColors.teal,
        )
        Spacer(Modifier.height(12.dp))
        // The actual garden scene (read-only) instead of a decorative placeholder.
        org.iremia.iremia.ui.garden.GardenScene(
            tiles = tiles,
            columns = columns,
            rows = rows,
            modifier = Modifier
                .fillMaxWidth()
                .clickable(onClick = onViewGarden),
        )
        Spacer(Modifier.height(14.dp))
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(10.dp),
        ) {
            // Primary: make an entry.
            Row(
                modifier = Modifier
                    .weight(1f)
                    .clip(RoundedCornerShape(percent = 50))
                    .background(HomeColors.teal)
                    .clickable(onClick = onMakeEntry)
                    .padding(vertical = 13.dp),
                horizontalArrangement = Arrangement.Center,
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Text(
                    text = localized(SharedRes.strings.home_make_entry).toString(context),
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Bold,
                    color = HomeColors.onTeal,
                )
            }
            // Secondary: view garden.
            Row(
                modifier = Modifier
                    .weight(1f)
                    .clip(RoundedCornerShape(percent = 50))
                    .border(1.5.dp, HomeColors.teal, RoundedCornerShape(percent = 50))
                    .clickable(onClick = onViewGarden)
                    .padding(vertical = 13.dp),
                horizontalArrangement = Arrangement.Center,
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Text(
                    text = localized(SharedRes.strings.home_view_garden).toString(context),
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Bold,
                    color = HomeColors.teal,
                )
            }
        }
    }
}


@Composable
private fun GreetingHeader() {
    val context = LocalContext.current
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(bottomStart = 30.dp, bottomEnd = 30.dp))
            .background(HomeColors.tealSoft)
            .statusBarsPadding()
            .padding(top = 18.dp, start = 22.dp, end = 22.dp, bottom = 26.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.SpaceBetween,
    ) {
        Column(Modifier.weight(1f)) {
            Text(
                text = localized(SharedRes.strings.home_greeting_evening).toString(context).uppercase(),
                fontSize = 12.sp,
                fontWeight = FontWeight.SemiBold,
                letterSpacing = 1.7.sp,
                color = HomeColors.ink.copy(alpha = 0.5f),
            )
            Spacer(Modifier.height(6.dp))
            Text(
                text = localized(SharedRes.strings.home_greeting_name).toString(context),
                fontSize = 32.sp,
                fontWeight = FontWeight.Bold,
                color = HomeColors.ink,
            )
            Spacer(Modifier.height(7.dp))
            Text(
                text = localized(SharedRes.strings.home_greeting_subtitle).toString(context),
                fontSize = 13.5.sp,
                color = HomeColors.inkSoft,
            )
        }
        // Avatar placeholder ring (real profile photo comes from the backend later).
        Box(
            modifier = Modifier
                .size(56.dp)
                .clip(CircleShape)
                .background(Color.White.copy(alpha = 0.65f)),
            contentAlignment = Alignment.Center,
        ) {
            Box(
                modifier = Modifier
                    .size(50.dp)
                    .clip(CircleShape)
                    .background(HomeColors.teal.copy(alpha = 0.25f)),
                contentAlignment = Alignment.Center,
            ) {
                Text("L", fontSize = 22.sp, fontWeight = FontWeight.Bold, color = HomeColors.tealDeep)
            }
        }
    }
}

@Composable
private fun HeroInsightCard(
    insight: MotivationInsight,
    modifier: Modifier = Modifier,
    onPointTap: (org.iremia.iremia.domain.insights.TrendPoint) -> Unit = {},
) {
    val context = LocalContext.current
    Column(
        modifier = modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(24.dp))
            .background(
                Brush.linearGradient(
                    colors = listOf(HomeColors.tealDeep, HomeColors.tealDeep2),
                    start = Offset(0f, 0f),
                    end = Offset(0f, Float.POSITIVE_INFINITY),
                )
            )
            .padding(18.dp),
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween,
        ) {
            Text(
                text = localized(SharedRes.strings.home_hero_label).toString(context),
                fontSize = 11.sp,
                fontWeight = FontWeight.Bold,
                letterSpacing = 1.3.sp,
                color = HomeColors.onTealMute,
            )
            Text(
                text = localized(SharedRes.strings.home_hero_no_rating).toString(context),
                fontSize = 10.5.sp,
                fontWeight = FontWeight.SemiBold,
                color = HomeColors.onTealMute,
                modifier = Modifier
                    .clip(RoundedCornerShape(percent = 50))
                    .border(1.dp, HomeColors.onTeal.copy(alpha = 0.22f), RoundedCornerShape(percent = 50))
                    .padding(horizontal = 9.dp, vertical = 3.dp),
            )
        }

        Spacer(Modifier.height(14.dp))
        // Crossfade the headline when it changes after a new entry, so the user
        // sees that something updated.
        val headlineText = localized(insight.headlineKeyRes()).toString(context)
        AnimatedContent(
            targetState = headlineText,
            transitionSpec = { fadeIn(tween(400)) togetherWith fadeOut(tween(200)) },
            label = "insight_headline",
        ) { text ->
            Text(
                text = text,
                fontSize = 23.sp,
                fontWeight = FontWeight.Bold,
                lineHeight = 28.sp,
                color = HomeColors.onTeal,
            )
        }
        Spacer(Modifier.height(16.dp))

        Box(
            Modifier
                .fillMaxWidth()
                .height(1.dp)
                .background(HomeColors.onTeal.copy(alpha = 0.16f))
        )
        Spacer(Modifier.height(14.dp))

        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween,
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Box(
                    modifier = Modifier
                        .size(34.dp)
                        .clip(RoundedCornerShape(11.dp))
                        .background(HomeColors.chartLine.copy(alpha = 0.18f)),
                    contentAlignment = Alignment.Center,
                ) {
                    Text(if (insight.isPositive) "↓" else "→", color = HomeColors.chartLine, fontSize = 16.sp, fontWeight = FontWeight.Bold)
                }
                Spacer(Modifier.width(10.dp))
                Column {
                    Text(
                        text = localized(insight.factTitleKeyRes()).toString(context),
                        fontSize = 14.5.sp,
                        fontWeight = FontWeight.Bold,
                        color = HomeColors.onTeal,
                    )
                    Text(
                        text = localized(insight.factSubtitleKeyRes()).toString(context),
                        fontSize = 12.sp,
                        color = HomeColors.onTeal.copy(alpha = 0.7f),
                    )
                }
            }
            TrendChart(
                points = insight.trend,
                trendPoints = insight.trendPoints,
                onPointTap = onPointTap,
                modifier = Modifier
                    .width(74.dp)
                    .height(34.dp),
            )
        }
    }
}

/**
 * Small line+area sparkline for the hero card. Higher value = higher on screen.
 * When [trendPoints] are present the chart is tappable: a tap maps to the nearest
 * point and reports it via [onPointTap] (Block 2).
 */
@Composable
private fun TrendChart(
    points: List<Float>,
    modifier: Modifier = Modifier,
    trendPoints: List<org.iremia.iremia.domain.insights.TrendPoint> = emptyList(),
    onPointTap: (org.iremia.iremia.domain.insights.TrendPoint) -> Unit = {},
) {
    if (points.size < 2) return
    val tapModifier = if (trendPoints.isNotEmpty()) {
        Modifier.pointerInput(trendPoints) {
            detectTapGestures { offset ->
                // Map the tap x-position to the nearest trend point index.
                val frac = (offset.x / size.width).coerceIn(0f, 1f)
                val index = (frac * (trendPoints.size - 1)).roundToInt().coerceIn(0, trendPoints.size - 1)
                onPointTap(trendPoints[index])
            }
        }
    } else Modifier
    androidx.compose.foundation.Canvas(modifier = modifier.then(tapModifier)) {
        val maxV = points.max()
        val minV = points.min()
        val range = (maxV - minV).takeIf { it > 0f } ?: 1f
        val stepX = size.width / (points.size - 1)
        fun x(i: Int) = i * stepX
        fun y(v: Float) = size.height - ((v - minV) / range) * size.height

        val linePath = Path().apply {
            moveTo(x(0), y(points[0]))
            for (i in 1 until points.size) lineTo(x(i), y(points[i]))
        }
        val areaPath = Path().apply {
            addPath(linePath)
            lineTo(x(points.size - 1), size.height)
            lineTo(x(0), size.height)
            close()
        }
        drawPath(
            areaPath,
            brush = Brush.verticalGradient(
                colors = listOf(HomeColors.chartLine.copy(alpha = 0.4f), Color.Transparent),
            ),
        )
        drawPath(
            linePath,
            color = HomeColors.chartLine,
            style = Stroke(width = 2.dp.toPx(), cap = StrokeCap.Round, join = StrokeJoin.Round),
        )
        drawCircle(HomeColors.onTeal, radius = 2.6.dp.toPx(), center = Offset(x(points.size - 1), y(points.last())))
    }
}

@Composable
private fun PatternsSection(modifier: Modifier = Modifier) {
    val context = LocalContext.current
    val cards = remember {
        listOf(
            PatternCardData(SharedRes.strings.home_pattern_move_title, SharedRes.strings.home_pattern_move_meta),
            PatternCardData(SharedRes.strings.home_pattern_evening_title, SharedRes.strings.home_pattern_evening_meta),
            PatternCardData(SharedRes.strings.home_pattern_breath_title, SharedRes.strings.home_pattern_breath_meta),
        )
    }
    Column(modifier = modifier.fillMaxWidth()) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween,
        ) {
            Text(
                text = localized(SharedRes.strings.home_patterns_title).toString(context),
                fontSize = 18.sp,
                fontWeight = FontWeight.Bold,
                color = HomeColors.ink,
            )
            Text(
                text = localized(SharedRes.strings.home_patterns_auto).toString(context),
                fontSize = 11.sp,
                fontWeight = FontWeight.SemiBold,
                color = HomeColors.teal,
            )
        }
        Spacer(Modifier.height(12.dp))
        cards.forEachIndexed { index, data ->
            PatternCard(data)
            if (index < cards.lastIndex) Spacer(Modifier.height(10.dp))
        }
    }
}

@Composable
private fun PatternCard(data: PatternCardData) {
    val context = LocalContext.current
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(18.dp))
            .background(HomeColors.card)
            .border(1.dp, HomeColors.line, RoundedCornerShape(18.dp))
            .padding(14.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Column(Modifier.weight(1f)) {
            Text(
                text = localized(data.titleRes).toString(context),
                fontSize = 14.5.sp,
                fontWeight = FontWeight.SemiBold,
                lineHeight = 18.sp,
                color = HomeColors.ink,
            )
            Spacer(Modifier.height(3.dp))
            Text(
                text = localized(data.metaRes).toString(context),
                fontSize = 12.sp,
                color = HomeColors.inkMute,
            )
        }
        Spacer(Modifier.width(10.dp))
        MiniBars()
    }
}

/** Seven-bar sparkline placeholder shown on each pattern card. */
@Composable
private fun MiniBars() {
    androidx.compose.foundation.Canvas(modifier = Modifier.size(width = 46.dp, height = 22.dp)) {
        val bars = 7
        val barW = 3.4.dp.toPx()
        val gap = (size.width - bars * barW) / (bars - 1)
        val heights = listOf(0.45f, 0.6f, 0.5f, 0.7f, 0.6f, 0.85f, 1f)
        for (i in 0 until bars) {
            val h = size.height * heights[i]
            val left = i * (barW + gap)
            val color = if (i == bars - 1) HomeColors.teal else HomeColors.teal.copy(alpha = 0.28f)
            drawRoundRect(
                color = color,
                topLeft = Offset(left, size.height - h),
                size = androidx.compose.ui.geometry.Size(barW, h),
                cornerRadius = androidx.compose.ui.geometry.CornerRadius(1.7.dp.toPx()),
            )
        }
    }
}

@Composable
private fun DailyFlashcard(modifier: Modifier = Modifier) {
    val context = LocalContext.current
    val cards = remember {
        listOf(
            SharedRes.strings.home_flashcard_1,
            SharedRes.strings.home_flashcard_2,
            SharedRes.strings.home_flashcard_3,
            SharedRes.strings.home_flashcard_4,
            SharedRes.strings.home_flashcard_5,
        )
    }
    var index by remember { mutableIntStateOf(0) }

    Column(
        modifier = modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(20.dp))
            .background(HomeColors.tealSofter)
            .border(1.dp, HomeColors.line, RoundedCornerShape(20.dp))
            .padding(16.dp),
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Text(
                text = localized(SharedRes.strings.home_flashcard_label).toString(context),
                fontSize = 11.sp,
                fontWeight = FontWeight.Bold,
                letterSpacing = 1.1.sp,
                color = HomeColors.teal,
            )
            Text(
                text = "${index + 1} / ${cards.size}",
                fontSize = 11.sp,
                fontWeight = FontWeight.SemiBold,
                color = HomeColors.inkMute,
            )
        }
        Spacer(Modifier.height(12.dp))
        AnimatedContent(
            targetState = index,
            transitionSpec = {
                (fadeIn(tween(320)) togetherWith fadeOut(tween(160)))
            },
            label = "flashcard",
        ) { i ->
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .heightIn(min = 96.dp)
                    .clip(RoundedCornerShape(14.dp))
                    .background(HomeColors.card)
                    .padding(horizontal = 18.dp, vertical = 20.dp),
                contentAlignment = Alignment.CenterStart,
            ) {
                Text(
                    text = localized(cards[i]).toString(context),
                    fontSize = 15.5.sp,
                    fontWeight = FontWeight.Medium,
                    lineHeight = 22.sp,
                    color = HomeColors.ink,
                )
            }
        }
        Spacer(Modifier.height(12.dp))
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically,
        ) {
            IconButton(
                onClick = { if (index > 0) index-- },
                modifier = Modifier
                    .size(34.dp)
                    .clip(CircleShape)
                    .background(HomeColors.card)
                    .border(1.dp, HomeColors.line, CircleShape),
            ) {
                Icon(
                    Icons.AutoMirrored.Filled.KeyboardArrowLeft,
                    contentDescription = localized(SharedRes.strings.home_flashcard_prev).toString(context),
                    tint = HomeColors.teal,
                )
            }
            Row(verticalAlignment = Alignment.CenterVertically) {
                cards.indices.forEach { i ->
                    Box(
                        modifier = Modifier
                            .padding(horizontal = 3.dp)
                            .height(6.dp)
                            .width(if (i == index) 18.dp else 6.dp)
                            .clip(RoundedCornerShape(3.dp))
                            .background(if (i == index) HomeColors.teal else HomeColors.teal.copy(alpha = 0.22f))
                    )
                }
            }
            IconButton(
                onClick = { if (index < cards.lastIndex) index++ },
                modifier = Modifier
                    .size(34.dp)
                    .clip(CircleShape)
                    .background(HomeColors.card)
                    .border(1.dp, HomeColors.line, CircleShape),
            ) {
                Icon(
                    Icons.AutoMirrored.Filled.KeyboardArrowRight,
                    contentDescription = localized(SharedRes.strings.home_flashcard_next).toString(context),
                    tint = HomeColors.teal,
                )
            }
        }
    }
}

// The mock insight uses fixed keys; these helpers resolve the enum-keyed copy so
// the real algorithm can vary headline/fact by (isPositive, confidence) later.
private fun MotivationInsight.headlineKeyRes(): StringResource = resolveStringKey(headlineKey)
private fun MotivationInsight.factTitleKeyRes(): StringResource = resolveStringKey(factTitleKey)
private fun MotivationInsight.factSubtitleKeyRes(): StringResource = resolveStringKey(factSubtitleKey)

/**
 * Maps a string key produced by the insight model to its moko [StringResource].
 * Central place so both the mock and the algorithm agree on the same keys.
 */
private fun resolveStringKey(key: String): StringResource = when (key) {
    "insight_headline_positive_high" -> SharedRes.strings.insight_headline_positive_high
    "insight_headline_positive_medium" -> SharedRes.strings.insight_headline_positive_medium
    "insight_headline_positive_low" -> SharedRes.strings.insight_headline_positive_low
    "insight_headline_neutral_high" -> SharedRes.strings.insight_headline_neutral_high
    "insight_headline_neutral_medium" -> SharedRes.strings.insight_headline_neutral_medium
    "insight_headline_neutral_low" -> SharedRes.strings.insight_headline_neutral_low
    "insight_fact_fewer_attacks" -> SharedRes.strings.insight_fact_fewer_attacks
    "insight_fact_steady_attacks" -> SharedRes.strings.insight_fact_steady_attacks
    "insight_fact_vs_prev_30" -> SharedRes.strings.insight_fact_vs_prev_30
    "insight_fact_keep_going" -> SharedRes.strings.insight_fact_keep_going
    else -> SharedRes.strings.insight_headline_neutral_low
}
