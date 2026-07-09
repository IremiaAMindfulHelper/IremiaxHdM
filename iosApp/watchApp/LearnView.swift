import SwiftUI

// MARK: - Model

/// One knowledge card. `id` mirrors the entry id in `iremia_rag.json` (e.g.
/// "PA001") so the English Learn copy here can be traced back to the German
/// source that also feeds the Claude knowledge base.
struct LearnArticle: Identifiable {
    let id: String
    let title: String
    let body: String
}

/// A sub-section within a chapter (e.g. "Basics", "Symptoms"), grouping a few
/// related articles — mirrors the `category` field of the source entries.
struct LearnGroup: Identifiable {
    var id: String { label }
    let label: String
    let articles: [LearnArticle]
}

/// A top-level theme in the Learn menu. Chapters follow a deliberate arc:
/// understand → act → work with thoughts → prevent → emergency.
struct LearnChapter: Identifiable {
    let id: Int
    let title: String
    /// One-line didactic intent shown at the top of the chapter.
    let intent: String
    let symbol: String
    /// Emergency chapter is accented in copper instead of teal.
    let isEmergency: Bool
    let groups: [LearnGroup]

    var accent: Color { isEmergency ? .iremiaQuickHelp : .iremiaJourneyTitle }
    var articleCount: Int { groups.reduce(0) { $0 + $1.articles.count } }
}

// MARK: - Home (chapter list)

struct LearnHomeView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(LearnContent.chapters) { chapter in
                    NavigationLink {
                        LearnChapterView(chapter: chapter)
                    } label: {
                        LearnChapterRow(chapter: chapter)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 8)
            .padding(.top, 4)
        }
        .background { LearnBackground() }
        .navigationTitle("Learn")
    }
}

private struct LearnChapterRow: View {
    let chapter: LearnChapter

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: chapter.symbol)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(chapter.accent)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 1) {
                // "Understand" is one long word, so force a hyphenated break to
                // keep it two lines like the multi-word titles. Display-only —
                // the data model keeps the clean title for navigationTitle.
                Text(chapter.title == "Understand" ? "Under-\nstand" : chapter.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                Text("\(chapter.articleCount) topics")
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.6))
            }

            Spacer(minLength: 4)

            Image(systemName: "chevron.right")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.white.opacity(0.5))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: chapter.isEmergency
                            ? [Color.iremiaSOS.opacity(0.85), Color.iremiaSOS.opacity(0.35)]
                            : [Color.iremiaEntryBg.opacity(0.9), Color.iremiaJourneyTeal.opacity(0.4)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(chapter.accent.opacity(0.25), lineWidth: 1)
                )
        )
    }
}

// MARK: - Chapter (article list, grouped)

struct LearnChapterView: View {
    let chapter: LearnChapter

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(chapter.intent)
                    .font(.system(size: 13, weight: .medium))
                    .italic()
                    .foregroundStyle(chapter.accent)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 2)

                ForEach(chapter.groups) { group in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(group.label.uppercased())
                            .font(.system(size: 10, weight: .semibold))
                            .kerning(1.1)
                            .foregroundStyle(chapter.accent.opacity(0.8))

                        ForEach(group.articles) { article in
                            NavigationLink {
                                LearnArticleView(article: article, accent: chapter.accent)
                            } label: {
                                LearnArticleRow(title: article.title, accent: chapter.accent)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
        }
        .background { LearnBackground() }
        .navigationTitle(chapter.title)
    }
}

private struct LearnArticleRow: View {
    let title: String
    let accent: Color

    var body: some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 4)
            Image(systemName: "chevron.right")
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(accent.opacity(0.6))
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 9)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.iremiaEntryBg.opacity(0.16))
        )
    }
}

// MARK: - Article (detail)

struct LearnArticleView: View {
    let article: LearnArticle
    let accent: Color

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text(article.title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(accent)
                    .fixedSize(horizontal: false, vertical: true)

                Text(article.body)
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.92))
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
        }
        .background { LearnBackground() }
        .navigationTitle("Learn")
    }
}

// MARK: - Shared background

private struct LearnBackground: View {
    var body: some View {
        LinearGradient(
            colors: [Color.iremiaJourneyTeal.opacity(0.35), Color.black],
            startPoint: .top,
            endPoint: .center
        )
        .ignoresSafeArea()
    }
}
