import Foundation

/// Curated Learn content for the Watch — English copy grouped into five
/// didactic chapters (understand → act → work with thoughts → prevent →
/// emergency). Each article's `id` maps to the German source entry in
/// `iremia_rag.json`, which stays untouched as the Claude knowledge base.
enum LearnContent {
    static let chapters: [LearnChapter] = [

        // MARK: 01 — Understand
        LearnChapter(
            id: 1,
            title: "Understand",
            intent: "This can't hurt you. Here's what's really happening in your body and mind.",
            symbol: "brain.head.profile",
            isEmergency: false,
            groups: [
                LearnGroup(label: "Basics", articles: [
                    LearnArticle(
                        id: "PA001",
                        title: "What is a panic attack?",
                        body: "A panic attack is a sudden episode of intense fear that triggers strong physical reactions, even though there is no real danger. It begins abruptly, typically peaks within 10 minutes, and then usually subsides. Panic attacks are not life-threatening."
                    ),
                    LearnArticle(
                        id: "PA002",
                        title: "How long does a panic attack last?",
                        body: "The most intense phase of a panic attack usually lasts 5 to 10 minutes. The total duration is rarely more than 20 to 30 minutes. Knowing that the attack ends on its own can make the situation more bearable."
                    ),
                    LearnArticle(
                        id: "PA003",
                        title: "Are panic attacks dangerous?",
                        body: "Panic attacks are not medically dangerous. Although they can feel life-threatening, no one has ever died from a panic attack. Physical symptoms like a racing heart or shortness of breath are the expression of an over-revved stress response, not a medical emergency."
                    ),
                    LearnArticle(
                        id: "PA005",
                        title: "What triggers a panic attack?",
                        body: "Panic attacks can be brought on by stress, lack of sleep, caffeine, or certain medications — or occur with no recognisable trigger at all. They arise from misinterpreting physical sensations as threatening, which sets off a vicious cycle of fear and physical reaction."
                    ),
                ]),
                LearnGroup(label: "Symptoms", articles: [
                    LearnArticle(
                        id: "PA006",
                        title: "A racing heart",
                        body: "A racing or pounding heart is one of the most common symptoms of a panic attack. It's caused by a surge of adrenaline that makes the heart beat faster. This is a normal protective response of the body — not a sign of heart disease."
                    ),
                    LearnArticle(
                        id: "PA007",
                        title: "Shortness of breath",
                        body: "The feeling of not getting enough air during a panic attack often comes from hyperventilation. Paradoxically, you're breathing too much, which lowers the CO₂ in your blood and intensifies tingling, dizziness, and the sense of breathlessness. Your body does not stop breathing."
                    ),
                    LearnArticle(
                        id: "PA008",
                        title: "Derealisation",
                        body: "Derealisation is the feeling that your surroundings are unreal, strange, or dreamlike. It occurs in up to 74% of panic attacks. Neurobiologically it comes from heightened amygdala activity that temporarily alters normal perception. It is completely harmless."
                    ),
                    LearnArticle(
                        id: "PA009",
                        title: "Depersonalisation",
                        body: "Depersonalisation is the feeling of being detached from yourself, as if observing yourself from the outside. It's closely related to derealisation and is a normal symptom of panic attacks. It is not a sign of a psychotic illness."
                    ),
                    LearnArticle(
                        id: "PA011",
                        title: "Dizziness",
                        body: "Dizziness during a panic attack comes from hyperventilation and the associated drop in blood CO₂, which briefly changes blood flow in the brain. It's unpleasant but harmless, and passes as your breathing returns to normal."
                    ),
                    LearnArticle(
                        id: "PA016",
                        title: "The fear of dying",
                        body: "The conviction that you're about to die is one of the most common cognitive symptoms of a panic attack. This conviction is a symptom of the panic itself — not a description of reality. No one has ever died from the physical symptoms of a panic attack."
                    ),
                    LearnArticle(
                        id: "PA017",
                        title: "The fear of losing control",
                        body: "Many people fear during a panic attack that they'll lose control, faint, or go mad. These fears are symptoms of the panic. Fainting typically does not occur during a panic attack, because blood pressure is raised, not lowered."
                    ),
                ]),
                LearnGroup(label: "The cycle", articles: [
                    LearnArticle(
                        id: "PA020",
                        title: "The vicious cycle of panic",
                        body: "The vicious cycle describes how physical sensations get read as threatening, which produces more fear, which in turn intensifies the physical symptoms. Breaking this cycle by accepting the sensations is a central goal of therapy."
                    ),
                ]),
                LearnGroup(label: "The anxious body", articles: [
                    LearnArticle(
                        id: "PH001",
                        title: "The fight-or-flight response",
                        body: "Fight-or-flight is an evolutionary survival mechanism. When danger is perceived, the brain fires up the sympathetic nervous system: heart rate and breathing speed up, muscles tense, the senses sharpen. In anxiety disorders, it's triggered by mistake."
                    ),
                    LearnArticle(
                        id: "PH003",
                        title: "The vagus nerve and calm",
                        body: "The vagus nerve is the key nerve of the parasympathetic nervous system, connecting the brain, heart, lungs, and gut. Stimulating it through slow breathing, humming, or cold water lowers heart rate and the stress response directly."
                    ),
                    LearnArticle(
                        id: "PH006",
                        title: "What hyperventilation does",
                        body: "When you hyperventilate you exhale too much CO₂, which raises your blood pH. That changes how excitable your nerve cells are and leads to tingling, dizziness, numbness, and muscle twitches. Slowing your breathing normalises CO₂ quickly and ends these symptoms."
                    ),
                    LearnArticle(
                        id: "PH007",
                        title: "Why fainting is rare",
                        body: "Fainting happens when blood pressure drops sharply. During a panic attack, though, blood pressure is typically raised — so genuine fainting is very rare. The feeling of being about to faint is almost always just a symptom, not a real danger."
                    ),
                ]),
                LearnGroup(label: "Anxiety, broadly", articles: [
                    LearnArticle(
                        id: "AN009",
                        title: "Anxiety is a protective program",
                        body: "Anxiety isn't a malfunction but an evolutionarily important protective program. In an anxiety disorder this system is simply set too sensitively — it reacts to harmless cues as if they were dangerous. Understanding this is a first step toward decatastrophizing."
                    ),
                    LearnArticle(
                        id: "AN010",
                        title: "Anxiety is not the same as danger",
                        body: "Feeling anxious does not mean a real danger exists. The brain can perceive threats where there are none. The sensation of anxiety and the actual presence of danger are two completely separate things."
                    ),
                ]),
            ]
        ),

        // MARK: 02 — In the moment
        LearnChapter(
            id: 2,
            title: "In the moment",
            intent: "When it hits, do this — right now, with your body.",
            symbol: "wind",
            isEmergency: false,
            groups: [
                LearnGroup(label: "Breathe", articles: [
                    LearnArticle(
                        id: "AT001",
                        title: "Box breathing",
                        body: "Inhale for 4 seconds, hold for 4, exhale for 4, hold for 4. This activates the parasympathetic nervous system and measurably lowers heart rate and cortisol. It's even used by elite units like the Navy SEALs to regulate stress."
                    ),
                    LearnArticle(
                        id: "AT002",
                        title: "4-7-8 breathing",
                        body: "Inhale through your nose for 4 seconds, hold for 7, exhale through your mouth for 8. The long exhale stimulates the vagus nerve and triggers the relaxation response. Practised twice a day, it reduces chronic anxiety."
                    ),
                    LearnArticle(
                        id: "AT003",
                        title: "The physiological sigh",
                        body: "Two short inhales through the nose, then one long exhale through the mouth. A Stanford study (2023) found this reduces stress faster than box breathing or meditation. Simple, fast, and highly effective."
                    ),
                    LearnArticle(
                        id: "AT005",
                        title: "Extend your exhale",
                        body: "A simple rule of thumb: exhale twice as long as you inhale — for example, in for 4, out for 8. The extended exhale activates the vagus nerve and signals safety to the brain. You can do it anytime, anywhere, discreetly."
                    ),
                    LearnArticle(
                        id: "AT006",
                        title: "Why exhaling calms you",
                        body: "Inhaling activates the sympathetic nervous system (stress); exhaling activates the parasympathetic (calm). By deliberately lengthening your exhale, you can actively slow your heartbeat — a well-established mechanism that works immediately."
                    ),
                ]),
                LearnGroup(label: "Ground", articles: [
                    LearnArticle(
                        id: "GR001",
                        title: "5-4-3-2-1 grounding",
                        body: "Name 5 things you can see, 4 you can hear, 3 you can touch, 2 you can smell, 1 you can taste. This draws your attention to the present moment and interrupts the spiral of panicked thoughts."
                    ),
                    LearnArticle(
                        id: "GR002",
                        title: "Feet on the ground",
                        body: "Stand or sit with both feet firmly on the floor. Feel the contact between your feet and the ground. Press your soles down deliberately and notice how the floor holds you. This signals physical safety to your nervous system."
                    ),
                    LearnArticle(
                        id: "GR003",
                        title: "Cold water",
                        body: "Cold water on your wrists, neck, or face activates the body's dive reflex, which reflexively slows your heartbeat. It's one of the fastest physiological ways to de-escalate a panic response."
                    ),
                    LearnArticle(
                        id: "GR005",
                        title: "Mental grounding — categories",
                        body: "Name items in a category in your head: everything red in the room, countries starting with A, kinds of animals. This engages the prefrontal cortex and weakens amygdala activation. The brain can't process fear and concentrate hard at the same time."
                    ),
                    LearnArticle(
                        id: "GR008",
                        title: "Progressive muscle relaxation",
                        body: "Progressive muscle relaxation (Jacobson) means deliberately tensing and then releasing muscle groups. The contrast between tension and release produces deep physical relaxation. PMR is clinically proven to reduce anxiety and panic."
                    ),
                ]),
            ]
        ),

        // MARK: 03 — Mind & thoughts
        LearnChapter(
            id: 3,
            title: "Mind & thoughts",
            intent: "Your thoughts feel true — but they aren't facts.",
            symbol: "text.bubble",
            isEmergency: false,
            groups: [
                LearnGroup(label: "Reframe", articles: [
                    LearnArticle(
                        id: "CB002",
                        title: "Thoughts are not facts",
                        body: "Thoughts like \"I'm dying\" or \"I'm losing control\" during a panic attack feel absolutely true, but they aren't facts. CBT teaches you to see thoughts as mental events that come and go — not as a mirror of reality."
                    ),
                    LearnArticle(
                        id: "CB005",
                        title: "Exposure and habituation",
                        body: "Avoiding anxiety-provoking situations reinforces anxiety over time. Gradually facing feared cues (exposure) leads to habituation — the brain learns the situation isn't dangerous. Exposure is the most effective technique against avoidance."
                    ),
                    LearnArticle(
                        id: "CB007",
                        title: "Acceptance over control",
                        body: "Trying to control or suppress anxious feelings often intensifies them. Accepting the sensations — noticing them without fighting — paradoxically lowers their intensity. Acceptance isn't surrender; it's giving up the struggle."
                    ),
                    LearnArticle(
                        id: "CB008",
                        title: "Thought defusion (ACT)",
                        body: "ACT teaches you to defuse thoughts: instead of \"I'm dying,\" reframe it as \"I notice the thought that I'm dying.\" This small linguistic distance markedly reduces the emotional punch of anxious thoughts."
                    ),
                ]),
                LearnGroup(label: "Observe", articles: [
                    LearnArticle(
                        id: "AC002",
                        title: "What is mindfulness?",
                        body: "Mindfulness means noticing the present moment consciously and without judgment. With anxiety, it helps you step out of automatic catastrophic thinking and watch sensations and thoughts as passing events rather than absolute truths."
                    ),
                    LearnArticle(
                        id: "AC004",
                        title: "The RAIN technique",
                        body: "RAIN is a mindfulness technique for hard emotions: Recognise, Allow, Investigate, Nurture (meet yourself with self-compassion). It helps you observe anxiety with curiosity and kindness instead of fighting it."
                    ),
                ]),
                LearnGroup(label: "Recovery is possible", articles: [
                    LearnArticle(
                        id: "GE002",
                        title: "Your brain can change",
                        body: "The brain stays plastic throughout life — it changes through experience, therapy, and targeted practice. Successful anxiety treatment produces measurable changes in brain structure and activity. Neuroplasticity is the biological basis for recovery."
                    ),
                ]),
            ]
        ),

        // MARK: 04 — Everyday care
        LearnChapter(
            id: 4,
            title: "Everyday care",
            intent: "Fewer attacks start with how you live.",
            symbol: "leaf",
            isEmergency: false,
            groups: [
                LearnGroup(label: "Daily foundations", articles: [
                    LearnArticle(
                        id: "SC001",
                        title: "Sleep and anxiety",
                        body: "Lack of sleep raises amygdala activity by up to 60% and weakens the regulating effect of the prefrontal cortex. Even one poor night measurably increases your readiness for anxiety. Enough sleep (7–9 hours) is one of the most important ways to prevent it."
                    ),
                    LearnArticle(
                        id: "BE001",
                        title: "Exercise as treatment",
                        body: "Regular physical activity is one of the most effective measures against anxiety. Aerobic endurance exercise (30 minutes, 3–5× a week) reduces anxiety comparably to antidepressants. Movement clears stress hormones and boosts endorphins and BDNF."
                    ),
                    LearnArticle(
                        id: "ER001",
                        title: "Caffeine and anxiety",
                        body: "Caffeine activates the sympathetic nervous system. High amounts can amplify anxiety symptoms and encourage panic attacks, especially if you already have an anxiety disorder. If you're prone to anxiety, cutting back clearly is advisable."
                    ),
                    LearnArticle(
                        id: "SE001",
                        title: "Self-compassion",
                        body: "Self-criticism and shame reinforce anxiety. Self-compassion — being as caring toward yourself as you would toward a good friend — is an effective antidote. Studies show it strengthens emotional resilience and reduces anxiety."
                    ),
                ]),
            ]
        ),

        // MARK: 05 — Emergency
        LearnChapter(
            id: 5,
            title: "Emergency",
            intent: "How to tell a panic attack from a real emergency — and where to get help right now.",
            symbol: "cross.case.fill",
            isEmergency: true,
            groups: [
                LearnGroup(label: "When it's more than panic", articles: [
                    LearnArticle(
                        id: "NO001",
                        title: "When to call emergency services",
                        body: "For genuine physical emergencies — persistent severe chest pain, paralysis, loss of speech, or unconsciousness — call emergency services (112) immediately. Panic attacks produce similar symptoms but are medically harmless. When in doubt, always seek medical help."
                    ),
                    LearnArticle(
                        id: "NO002",
                        title: "Crisis line (Germany)",
                        body: "If you're having thoughts of suicide or self-harm, immediate help matters. In Germany the Telefonseelsorge is free and available around the clock: 0800 111 0 111 or 0800 111 0 222. These services are anonymous and free of charge."
                    ),
                ]),
            ]
        ),
    ]
}
