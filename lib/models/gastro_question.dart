class GastroQuestion {
  final int id; // 1 to 27
  final int worldId; // 1 to 6 (thematic stages)
  final String questionText;
  final List<String> options;
  final int correctOptionIndex; // 0 for a, 1 for b, 2 for c, etc.
  final String explanation;
  final String anatomicalTheme;
  final String ficheTitle;
  final List<String> fichePoints;
  final String whyOthersWrong;
  final String diagramType;
  final bool validated;

  const GastroQuestion({
    required this.id,
    required this.worldId,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
    required this.anatomicalTheme,
    this.ficheTitle = '',
    this.fichePoints = const [],
    this.whyOthersWrong = '',
    this.diagramType = '',
    this.validated = true,
  });

  // Getter compatibility
  int get originalNumber => id;

  String get correctLetter {
    const letters = ['a', 'b', 'c', 'd', 'e'];
    if (correctOptionIndex >= 0 && correctOptionIndex < letters.length) {
      return letters[correctOptionIndex];
    }
    return '';
  }

  String get correctOptionText {
    if (correctOptionIndex >= 0 && correctOptionIndex < options.length) {
      return options[correctOptionIndex];
    }
    return '';
  }
}

/// Les 27 questions officielles du Questionnaire PFE — MICI (ISSIT).
/// Reproduction exacte mot pour mot de l'intégralité du document source officiel.
final List<GastroQuestion> allGastroQuestions = [
  // =========================================================================
  // MONDE 1 : Anatomie, Physiologie et Lésions Intestinales (Q1 à Q4)
  // =========================================================================
  const GastroQuestion(
    id: 1,
    worldId: 1,
    questionText: 'Une fistule :',
    options: [
      'a. Est un trajet anormal entre deux parties d\'intestin ou entre l\'intestin et la peau',
      'b. Est un rétrécissement de l\'intestin qui peut obstruer le passage de son contenu',
    ],
    correctOptionIndex: 0,
    explanation:
        'Une fistule est un conduit anormal faisant communiquer deux cavités (entéro-entérique, entéro-colique, entéro-vésicale) ou reliant un segment intestinal à la peau (fistule entéro-cutanée ou ano-périnéale, fréquente dans la maladie de Crohn). À l\'inverse, un rétrécissement de l\'intestin est une sténose.',
    anatomicalTheme: 'Anatomie, Physiologie et Lésions Intestinales',
    ficheTitle: 'FISTULE VS STÉNOSE',
    fichePoints: [
      'Fistule = trajet de communication anormal (intestin-intestin ou intestin-peau).',
      'Sténose = rétrécissement de la lumière intestinale avec risque d\'occlusion.',
      'Complications caractéristiques de l\'atteinte transmurale de la maladie de Crohn.',
    ],
    whyOthersWrong:
        'L\'option (b) décrit une sténose (rétrécissement fibreux ou inflammatoire de la lumière intestinale), et non une fistule qui crée un canal de communication anormal.',
    diagramType: 'fistula_stenosis',
  ),
  const GastroQuestion(
    id: 2,
    worldId: 1,
    questionText:
        'Il y a des millions de petits « replis » dans l\'intestin grêle qui augmentent la surface d\'absorption. Ils sont appelés :',
    options: [
      'a. Les villosités',
      'b. Les enzymes',
      'c. Les sels biliaires',
      'd. Les cryptes',
    ],
    correctOptionIndex: 0,
    explanation:
        'Les villosités intestinales sont de minuscules replis digitiformes de la muqueuse de l\'intestin grêle. Avec les microvillosités des entérocytes, elles démultiplient la surface d\'absorption jusqu\'à environ 250 m², optimisant le passage des nutriments vers le sang.',
    anatomicalTheme: 'Anatomie, Physiologie et Lésions Intestinales',
    ficheTitle: 'VILLOSITÉS ET ABSORPTION',
    fichePoints: [
      'Villosités = replis digitiformes augmentant la surface d\'échange (jusqu\'à 250 m²).',
      'L\'inflammation du grêle détruit les villosités et provoque une malabsorption.',
      'Les cryptes de Lieberkühn sont situées à la base et assurent le renouvellement cellulaire.',
    ],
    whyOthersWrong:
        'Les enzymes (b) découpent chimiquement les aliments, les sels biliaires (c) émulsionnent les lipides, et les cryptes (d) sont des invaginations glandulaires au pied des villosités : aucune ne constitue ces replis saillants d\'absorption.',
    diagramType: 'villi_absorption',
  ),
  const GastroQuestion(
    id: 3,
    worldId: 1,
    questionText: 'La fonction du colon est d\'absorber :',
    options: [
      'a. Des vitamines',
      'b. Des nutriments (sucres, graisses, protéines)',
      'c. De l\'eau',
    ],
    correctOptionIndex: 2,
    explanation:
        'La fonction physiologique majeure du côlon (gros intestin) est la réabsorption massive d\'eau (environ 1,5 L par jour) et d\'électrolytes (sodium, chlore), permettant de concentrer et former les selles. Les nutriments (glucides, lipides, protides) sont absorbés en amont dans l\'intestin grêle.',
    anatomicalTheme: 'Anatomie, Physiologie et Lésions Intestinales',
    ficheTitle: 'PHYSIOLOGIE DU CÔLON',
    fichePoints: [
      'Rôle prépondérant du côlon = réabsorption d\'eau (1,5 L/24h) et des électrolytes.',
      'L\'intestin grêle absorbe l\'immense majorité des nutriments (sucres, graisses, protéines).',
      'Une atteinte colique (RCH, Crohn colique) altère la réabsorption d\'eau et entraîne des diarrhées.',
    ],
    whyOthersWrong:
        'La majorité des vitamines (a) et des nutriments tels que sucres, graisses et protéines (b) sont déjà absorbés en amont par l\'intestin grêle avant d\'atteindre le côlon.',
    diagramType: 'colon_water',
  ),
  const GastroQuestion(
    id: 4,
    worldId: 1,
    questionText: 'L\'iléon terminal :',
    options: [
      'a. Est la section d\'intestin juste avant l\'anus',
      'b. Est la section d\'intestin juste avant le colon',
    ],
    correctOptionIndex: 1,
    explanation:
        'L\'iléon terminal est l\'ultime segment de l\'intestin grêle. Il s\'abouche dans le caecum (début du côlon) au niveau de la valvule iléo-caecale de Bauhin. C\'est le site d\'élection de l\'inflammation dans la maladie de Crohn (iléite terminale) et le lieu exclusif d\'absorption de la vitamine B12 et des sels biliaires.',
    anatomicalTheme: 'Anatomie, Physiologie et Lésions Intestinales',
    ficheTitle: 'L\'ILÉON TERMINAL',
    fichePoints: [
      'Dernière portion de l\'intestin grêle s\'abouchant directement dans le côlon.',
      'Siège privilégié de la maladie de Crohn (iléite).',
      'Site spécifique d\'absorption de la vitamine B12 et des sels biliaires.',
    ],
    whyOthersWrong:
        'L\'option (a) désigne le rectum et le canal anal situés tout à la fin du tube digestif, alors que l\'iléon terminal clôt l\'intestin grêle juste avant le côlon.',
    diagramType: 'ileum_valve',
  ),

  // =========================================================================
  // MONDE 2 : Généralités, Symptômes et Manifestations de la Maladie (Q5 à Q9)
  // =========================================================================
  const GastroQuestion(
    id: 5,
    worldId: 2,
    questionText: 'Si un enfant est atteint de MICI, il ou elle ne pourra pas :',
    options: [
      'a. Vivre au-delà de 45 ans',
      'b. Être aussi grand que ses amis',
      'c. Suivre des études supérieures',
      'd. Toutes les réponses sont fausses',
    ],
    correctOptionIndex: 3,
    explanation:
        'Toutes les réponses a, b et c sont fausses. Grâce aux thérapeutiques modernes et à une prise en charge précoce, un enfant atteint de MICI a une espérance de vie similaire à la population générale, peut rattraper son retard staturo-pondéral et mener des études universitaires ou une carrière professionnelle épanouie.',
    anatomicalTheme: 'Généralités, Symptômes et Manifestations de la Maladie',
    ficheTitle: 'MICI PÉDIATRIQUE & AVENIR',
    fichePoints: [
      'Espérance de vie quasi-normale avec un traitement d\'entretien rigoureux.',
      'Croissance et scolarité préservées grâce à la mise en rémission rapide.',
      'Un accompagnement infirmier et médical soutient le projet de vie complet de l\'enfant.',
    ],
    whyOthersWrong:
        'Les affirmations (a), (b) et (c) sont des idées reçues erronées : une MICI bien traitée n\'ampute ni l\'espérance de vie, ni la taille définitive, ni l\'accès aux études supérieures.',
    diagramType: 'systemic_mici',
  ),
  const GastroQuestion(
    id: 6,
    worldId: 2,
    questionText:
        'Un patient atteint de MICI a plus de risque d\'avoir, par rapport à la population générale :',
    options: [
      'a. Des douleurs articulaires',
      'b. Des maladies du cœur',
      'c. Des maladies des poumons',
      'd. Des maladies des reins',
    ],
    correctOptionIndex: 0,
    explanation:
        'Les douleurs et inflammations articulaires (arthralgies, arthrites périphériques, spondylarthrite ankylosante, sacro-iliite) sont les manifestations extra-intestinales les plus fréquentes des MICI, touchant entre 20 et 30 % des patients.',
    anatomicalTheme: 'Généralités, Symptômes et Manifestations de la Maladie',
    ficheTitle: 'MANIFESTATIONS ARTICULAIRES',
    fichePoints: [
      'Complications extra-intestinales les plus fréquentes (20 à 30 % des cas).',
      'Atteintes périphériques (grosses articulations) souvent corrélées aux poussées digestives.',
      'Atteintes axiales (rachis, bassin) évoluant indépendamment des poussées coliques.',
    ],
    whyOthersWrong:
        'Les pathologies cardiaques (b), pulmonaires (c) ou rénales (d) ne constituent pas les manifestations extra-digestives caractéristiques les plus fréquentes, contrairement aux atteintes articulaires.',
    diagramType: 'systemic_mici',
  ),
  const GastroQuestion(
    id: 7,
    worldId: 2,
    questionText: 'La rémission clinique :',
    options: [
      'a. Signifie que le patient est guéri de sa MICI',
      'b. Signifie qu\'il n\'a plus de symptômes de sa maladie (ni diarrhées, ni sang dans les selles, ni douleurs abdominales...)',
      'c. Signifie que la coloscopie ne retrouve pas de lésions dans l\'intestin',
      'd. Signifie que le traitement doit être arrêté',
    ],
    correctOptionIndex: 1,
    explanation:
        'La rémission clinique correspond à la disparition complète des symptômes cliniques ressentis par le patient (plus de douleurs abdominales, fréquence des selles normalisée, absence de rectorragies). Les MICI étant des affections chroniques, la rémission clinique n\'est pas synonyme de guérison définitive et ne doit jamais conduire à l\'arrêt du traitement de fond.',
    anatomicalTheme: 'Généralités, Symptômes et Manifestations de la Maladie',
    ficheTitle: 'LA RÉMISSION CLINIQUE',
    fichePoints: [
      'Disparition des symptômes (douleurs, diarrhées, saignements).',
      'Ne signifie ni guérison définitive (maladie chronique), ni arrêt du traitement.',
      'La rémission endoscopique (cicatrisation muqueuse) est un objectif complémentaire.',
    ],
    whyOthersWrong:
        'Les MICI ne se guérissent pas définitivement (a), l\'absence de lésions à la coloscopie définit la rémission endoscopique et non clinique (c), et arrêter le traitement expose à une rechute (d).',
    diagramType: 'systemic_mici',
  ),
  const GastroQuestion(
    id: 8,
    worldId: 2,
    questionText:
        'Parmi les propositions suivantes, laquelle n\'est pas un symptôme habituel des MICI :',
    options: [
      'a. Douleur abdominale',
      'b. Trouble du transit',
      'c. Céphalées',
      'd. Fièvre',
    ],
    correctOptionIndex: 2,
    explanation:
        'Les céphalées (maux de tête) ne sont pas un symptôme habituel ou spécifique des MICI. Les manifestations digestives typiques incluent les douleurs abdominales, les troubles chroniques du transit (diarrhées avec ou sans glaires et sang) et la fièvre lors des poussées aiguës ou des complications septiques (abcès).',
    anatomicalTheme: 'Généralités, Symptômes et Manifestations de la Maladie',
    ficheTitle: 'SYMPTÔMES CARDINAUX DES MICI',
    fichePoints: [
      'Symptômes digestifs typiques : douleurs abdominales, diarrhées chroniques, rectorragies.',
      'Signes généraux : fièvre (poussée/abcès), asthénie, perte de poids.',
      'Les céphalées ne sont pas un signe d\'appel clinique habituel des MICI.',
    ],
    whyOthersWrong:
        'Douleurs abdominales (a), troubles du transit (b) et fièvre lors des poussées ou abcès (d) font bien partie du tableau typique des MICI ; seules les céphalées (c) sont inhabituelles.',
    diagramType: 'systemic_mici',
  ),
  const GastroQuestion(
    id: 9,
    worldId: 2,
    questionText:
        'Les patients atteints de MICI peuvent développer de l\'inflammation dans d\'autres parties du corps autant que dans l\'intestin :',
    options: [
      'a. Vrai',
      'b. Faux',
    ],
    correctOptionIndex: 0,
    explanation:
        'Vrai. Les MICI sont des pathologies inflammatoires systémiques. L\'hyperactivation immunitaire peut atteindre d\'autres organes : articulations (arthrites), peau (érythème noueux, pyoderma gangrenosum), yeux (uvéite, épisclérite) et foie/voies biliaires (cholangite sclérosante primitive).',
    anatomicalTheme: 'Généralités, Symptômes et Manifestations de la Maladie',
    ficheTitle: 'MICI : MALADIES SYSTÉMIQUES',
    fichePoints: [
      'L\'inflammation dépasse la seule sphère digestive.',
      'Organes cibles : articulations, peau (érythème noueux), yeux (uvéites), foie/voies biliaires.',
      'Nécessite une prise en charge multidisciplinaire (gastro, rhumato, dermato, ophtalmo).',
    ],
    whyOthersWrong:
        'Dire « Faux » (b) méconnaîtrait la nature systémique des MICI, qui touchent souvent les articulations, la peau, les yeux ou les voies biliaires.',
    diagramType: 'systemic_mici',
  ),

  // =========================================================================
  // MONDE 3 : Traitements Médicamenteux et Observance (Q10 à Q12)
  // =========================================================================
  const GastroQuestion(
    id: 10,
    worldId: 3,
    questionText: 'Les biothérapies anti-TNF :',
    options: [
      'a. Favorisent la survenue d\'un cancer du colon',
      'b. Ne favorisent pas la survenue des cancers « solides » (ex : cancer du sein, de la prostate, du poumon...)',
      'c. Augmentent la survenue des cancers du sang ou des ganglions',
      'd. Sont systématiquement contre-indiquées chez les patients ayant déjà eu un cancer',
    ],
    correctOptionIndex: 1,
    explanation:
        'Les études de suivi et registres internationaux ont démontré que les biothérapies anti-TNF utilisées en monothérapie n\'augmentent pas le risque de cancers d\'organes solides (sein, prostate, poumon). En réduisant l\'inflammation chronique muqueuse, elles exercent même un rôle protecteur contre le cancer colorectal lié à la colite.',
    anatomicalTheme: 'Traitements Médicamenteux et Observance',
    ficheTitle: 'BIOTHÉRAPIES ANTI-TNF & CANCERS',
    fichePoints: [
      'Pas d\'augmentation démontrée du risque de cancers solides en monothérapie.',
      'Effet protecteur contre le cancer du côlon grâce au contrôle de l\'inflammation chronique.',
      'Bilan pré-thérapeutique rigoureux (recherche de tuberculose latente, sérologies virales).',
    ],
    whyOthersWrong:
        'Elles réduisent plutôt le risque colique lié à l\'inflammation (a), n\'élèvent pas significativement en monothérapie le risque de cancers hématologiques (c) et peuvent être discutées au cas par cas après un antécédent néoplasique guéri (d).',
    diagramType: 'biotherapy_tnf',
  ),
  const GastroQuestion(
    id: 11,
    worldId: 3,
    questionText: 'Concernant les biothérapies anti-TNF :',
    options: [
      'a. L\'efficacité du traitement ne diminue jamais avec le temps',
      'b. Si l\'efficacité du traitement n\'est pas visible au bout d\'un mois, cela veut dire que le traitement ne fonctionne pas',
      'c. L\'efficacité du traitement peut être modulée par la prise simultanée d\'immunosuppresseurs',
      'd. Si l\'efficacité du traitement diminue, il faut nécessairement changer de traitement',
    ],
    correctOptionIndex: 2,
    explanation:
        'La combothérapie associant un anti-TNF à un immunosuppresseur conventionnel (azathioprine ou méthotrexate) réduit considérablement l\'immunisation (formation d\'anticorps anti-médicament), augmente les taux sanguins résiduels de la biothérapie et maximise son efficacité à long terme.',
    anatomicalTheme: 'Traitements Médicamenteux et Observance',
    ficheTitle: 'COMBOTHÉRAPIE & IMMUNOMODULATION',
    fichePoints: [
      'L\'association anti-TNF + immunosuppresseur limite le risque d\'immunisation.',
      'Maintient des taux sanguins thérapeutiques stables de l\'anticorps monoclonal.',
      'En cas de perte d\'efficacité, un dosage pharmacologique (taux + anticorps) guide l\'adaptation.',
    ],
    whyOthersWrong:
        'Une perte d\'efficacité secondaire peut survenir (a), la réponse complète prend parfois plus d\'un mois d\'induction (b) et une baisse d\'effet peut souvent être rattrapée par optimisation de dose sans changer de molécule (d).',
    diagramType: 'biotherapy_tnf',
  ),
  const GastroQuestion(
    id: 12,
    worldId: 3,
    questionText: 'Chez un patient atteint de MICI prenant un traitement au long cours :',
    options: [
      'a. La prise régulière du traitement n\'a pas de réelle influence sur son efficacité',
      'b. Il est possible d\'arrêter soi-même le médicament si les symptômes disparaissent et de le reprendre quand ils réapparaissent',
      'c. La prise irrégulière d\'un traitement anti-TNF peut entraîner une perte d\'efficacité de celui-ci',
      'd. La prise irrégulière du traitement par anti-TNF n\'accroît pas le risque de réactions allergiques',
    ],
    correctOptionIndex: 2,
    explanation:
        'Une mauvaise observance ou l\'interruption intermittente d\'une biothérapie anti-TNF favorise l\'apparition d\'anticorps neutralisants anti-médicament. Cela provoque une perte d\'efficacité secondaire irréversible et majore grandement le risque de réactions anaphylactiques aiguës lors de la reprise des injections ou perfusions.',
    anatomicalTheme: 'Traitements Médicamenteux et Observance',
    ficheTitle: 'OBSERVANCE THÉRAPEUTIQUE',
    fichePoints: [
      'L\'observance stricte est la clé de voûte de la rémission prolongée.',
      'Les arrêts intempestifs déclenchent la fabrication d\'anticorps neutralisants.',
      'Risque accru de perte d\'efficacité et de réactions allergiques sévères à la reprise.',
    ],
    whyOthersWrong:
        'La régularité conditionne le maintien de la rémission (a), interrompre seul son traitement expose à une rechute (b) et augmente nettement le risque de réaction allergique à la reprise (d).',
    diagramType: 'biotherapy_tnf',
  ),

  // =========================================================================
  // MONDE 4 : Examens, Marqueurs Biologiques, Dépistage et Alimentation (Q13 à Q17)
  // =========================================================================
  const GastroQuestion(
    id: 13,
    worldId: 4,
    questionText: 'Au cours d\'une poussée de MICI :',
    options: [
      'a. Le taux de plaquettes dans le sang augmente',
      'b. Le taux d\'albumine dans le sang augmente',
      'c. Le taux de globules blancs diminue',
    ],
    correctOptionIndex: 0,
    explanation:
        'Lors d\'une poussée inflammatoire aiguë, la sécrétion massive de cytokines pro-inflammatoires (notamment l\'interleukine 6) stimule la thrombopoïèse, entraînant une thrombocytose réactionnelle (augmentation du taux de plaquettes). Parallèlement, on observe une hyperleucocytose et souvent une hypoalbuminémie consécutive à l\'inflammation et à la fuite digestive.',
    anatomicalTheme: 'Examens, Marqueurs Biologiques et Dépistage',
    ficheTitle: 'BIOLOGIE DE LA POUSSÉE INFLAMMATOIRE',
    fichePoints: [
      'Thrombocytose réactionnelle : élévation marquée des plaquettes sanguines.',
      'Hyperleucocytose à polynucléaires neutrophiles et élévation de la CRP.',
      'Baisse fréquente de l\'albumine (syndrome inflammatoire et pertes digestives).',
    ],
    whyOthersWrong:
        'Pendant une poussée, l\'albumine baisse par dénutrition et fuite digestive (b) tandis que les globules blancs ont au contraire tendance à augmenter (hyperleucocytose, c).',
    diagramType: 'biomarker_labs',
  ),
  const GastroQuestion(
    id: 14,
    worldId: 4,
    questionText:
        'Chez un patient souffrant d\'une MICI touchant le colon, en l\'absence de symptôme (diarrhée, douleur, fatigue...), une coloscopie :',
    options: [
      'a. Devrait être toujours réalisée une fois par an',
      'b. N\'est jamais nécessaire sauf en cas de récidive des symptômes',
      'c. Permet de dépister des lésions précancéreuses dans le colon',
      'd. Ne doit être réalisée qu\'après 50 ans',
    ],
    correctOptionIndex: 2,
    explanation:
        'Même en l\'absence de tout symptôme digestif, une coloscopie de surveillance avec chromoendoscopie et biopsies étagées est recommandée chez les patients ayant une colite évoluant depuis 8 à 10 ans. Elle permet de dépister la dysplasie et les lésions précancéreuses avant qu\'elles n\'évoluent vers un carcinome colorectal invasif.',
    anatomicalTheme: 'Examens, Marqueurs Biologiques et Dépistage',
    ficheTitle: 'COLOSCOPIE DE DÉPISTAGE',
    fichePoints: [
      'Indiquée après 8 à 10 ans d\'évolution de la colite, même en rémission clinique totale.',
      'Objectif fondamental : dépister la dysplasie et les lésions précancéreuses.',
      'Utilise la chromoendoscopie (coloration virtuelle ou vitale) pour repérer les anomalies muqueuses planes.',
    ],
    whyOthersWrong:
        'La fréquence dépend du niveau de risque (pas d\'office annuelle, a), la dysplasie évolue souvent sans symptôme (b) et la surveillance démarre selon l\'ancienneté de la colite plutôt qu\'à 50 ans (d).',
    diagramType: 'biomarker_labs',
  ),
  const GastroQuestion(
    id: 15,
    worldId: 4,
    questionText: 'Concernant le dosage de la CRP (Protéine C-réactive) :',
    options: [
      'a. Une CRP augmentée reflète toujours une MICI en poussée',
      'b. La CRP n\'est pas utile pour le suivi des MICI',
      'c. En l\'absence de symptôme, une CRP élevée sur plusieurs prises de sang consécutives doit faire réaliser d\'autres examens',
      'd. La CRP est plus fiable que la calprotectine fécale dans le cadre des MICI',
    ],
    correctOptionIndex: 2,
    explanation:
        'Une CRP élevée persistante chez un patient cliniquement asymptomatique témoigne souvent d\'une inflammation infraclinique active ou d\'une infection intercurrente. Cette anomalie biologique impose des investigations complémentaires (dosage de la calprotectine fécale, imagerie ou endoscopie) pour prévenir une rechute aiguë imminente.',
    anatomicalTheme: 'Examens, Marqueurs Biologiques et Dépistage',
    ficheTitle: 'LA CRP DANS LE SUIVI DES MICI',
    fichePoints: [
      'Marqueur plasmatique rapide d\'inflammation systémique.',
      'Une élévation persistante et silencieuse impose des examens complémentaires.',
      'La calprotectine fécale est un marqueur plus sensible et spécifique de l\'inflammation muqueuse intestinale.',
    ],
    whyOthersWrong:
        'La CRP augmente aussi lors d\'infections banales (a), reste un outil utile de suivi (b) mais demeure moins spécifique de la muqueuse intestinale que la calprotectine fécale (d).',
    diagramType: 'biomarker_labs',
  ),
  const GastroQuestion(
    id: 16,
    worldId: 4,
    questionText:
        'Laquelle parmi les propositions suivantes est fausse concernant le dépistage du cancer du colon ? Un dépistage devrait être proposé à tous les patients atteints de rectocolite hémorragique :',
    options: [
      'a. Qui n\'affecte que le rectum',
      'b. Qui évolue depuis 8 - 10 ans',
      'c. Qui a débuté avant l\'âge de 50 ans',
    ],
    correctOptionIndex: 0,
    explanation:
        'La proposition (a) est fausse. La rectite ulcéreuse isolée (RCH strictement limitée au rectum) n\'augmente pas significativement le risque de cancer du côlon. Le programme de surveillance endoscopique systématique ne s\'applique qu\'aux colites étendues (colite gauche et pancolite) après 8 à 10 ans d\'évolution.',
    anatomicalTheme: 'Examens, Marqueurs Biologiques et Dépistage',
    ficheTitle: 'CANCER COLORECTAL : PROTOCOLE DE DÉPISTAGE',
    fichePoints: [
      'La rectite isolée ne nécessite pas de protocole de surveillance spécifique du côlon.',
      'Les formes coliques étendues (pancolite) nécessitent une surveillance régulière après 8-10 ans.',
      'L\'association avec une cholangite sclérosante primitive impose un dépistage annuel immédiat.',
    ],
    whyOthersWrong:
        'Les options (b) durée de colite de 8-10 ans et (c) début jeune augmentent bien le sur-risque justifiant un dépistage ; seule la rectite strictement limitée au rectum (a) ne l\'exige pas.',
    diagramType: 'biomarker_labs',
  ),
  const GastroQuestion(
    id: 17,
    worldId: 4,
    questionText:
        'Les produits alimentaires de nutrition artificielle entérale sont parfois utilisés pour traiter la maladie de Crohn ou la RCH. Ils :',
    options: [
      'a. Contiennent toujours beaucoup de fibres',
      'b. Sont très faciles à digérer',
      'c. Sont présentés sous formes de comprimés',
    ],
    correctOptionIndex: 1,
    explanation:
        'Les mélanges de nutrition entérale exclusive (préparations liquides semi-élémentaires ou polymériques consommées par voie orale ou administrées par sonde nasogastrique) sont formulés pour être très faciles à digérer et à absorber. Dépourvus de résidus irritants, ils favorisent la mise au repos de la muqueuse, réduisent la dysbiose et constituent un traitement inducteur de rémission reconnu chez l\'enfant et l\'adolescent.',
    anatomicalTheme: 'Mode de vie, Alimentation et Voyages',
    ficheTitle: 'NUTRITION ENTÉRALE THÉRAPEUTIQUE',
    fichePoints: [
      'Formules liquides prédigérées, sans résidus ni fibres agressives.',
      'Traitement de choix en pédiatrie pour induire la rémission dans la maladie de Crohn.',
      'Corrige la dénutrition et favorise la régénération de la muqueuse digestive.',
    ],
    whyOthersWrong:
        'Ils sont pauvres en résidus et non riches en fibres (a), et se présentent en solutions liquides buvables ou pour sonde plutôt qu\'en comprimés (c).',
    diagramType: 'villi_absorption',
  ),

  // =========================================================================
  // MONDE 5 : Hérédité, Fertilité, Grossesse et Allaitement (Q18 à Q24)
  // =========================================================================
  const GastroQuestion(
    id: 18,
    worldId: 5,
    questionText: 'Les MICI peuvent être héréditaires :',
    options: [
      'a. Vrai',
      'b. Faux',
    ],
    correctOptionIndex: 0,
    explanation:
        'Vrai. Il existe une composante héréditaire prédisposante démontrée (plusieurs centaines de gènes identifiés dont NOD2/CARD15). Cependant, la transmission n\'est pas mendélienne directe : il s\'agit d\'une maladie multifactorielle résultant de l\'interaction entre un terrain génétique de susceptibilité, un dérèglement du microbiote et des facteurs environnementaux.',
    anatomicalTheme: 'Hérédité, Fertilité, Grossesse et Allaitement',
    ficheTitle: 'GÉNÉTIQUE & SUSCEPTIBILITÉ',
    fichePoints: [
      'Transmission génétique multifactorielle et non mendélienne directe.',
      'Le risque pour un enfant reste modéré (environ 2 à 5 % si un parent est touché).',
      'Facteurs déclenchants indispensables : microbiote intestinal, immunité, environnement.',
    ],
    whyOthersWrong:
        'Répondre « Faux » (b) ignorerait les plus de 200 gènes de susceptibilité identifiés (dont NOD2/CARD15) qui expliquent les formes familiales.',
    diagramType: 'pregnancy_genetics',
  ),
  const GastroQuestion(
    id: 19,
    worldId: 5,
    questionText: 'Si une femme est atteinte d\'une maladie de Crohn :',
    options: [
      'a. Elle peut avoir plus de difficultés pour être enceinte',
      'b. Elle ne devrait pas avoir d\'enfant',
      'c. Sa grossesse aura forcément des complications',
    ],
    correctOptionIndex: 0,
    explanation:
        'En période de poussée active de la maladie ou après certaines chirurgies abdomino-pelviennes (formation d\'adhérences tubaires), une femme atteinte de maladie de Crohn peut présenter des difficultés temporaires pour concevoir. En revanche, lorsque la maladie est stabilisée en rémission complète, la fertilité est strictement identique à celle des femmes indemnes de MICI.',
    anatomicalTheme: 'Hérédité, Fertilité, Grossesse et Allaitement',
    ficheTitle: 'FERTILITÉ & MALADIE DE CROHN',
    fichePoints: [
      'Fertilité normale en période de rémission clinique.',
      'Hypofertilité temporaire lors des poussées actives ou après chirurgie pelvienne.',
      'Rien ne contre-indique un projet de grossesse lorsque la maladie est contrôlée.',
    ],
    whyOthersWrong:
        'La grossesse n\'est nullement déconseillée (b) et évolue sans complication majeure dans la grande majorité des cas lorsque la rémission est obtenue (c).',
    diagramType: 'pregnancy_care',
  ),
  const GastroQuestion(
    id: 20,
    worldId: 5,
    questionText: 'Qu\'est-ce qui est le plus important lorsqu\'on essaye d\'avoir un bébé ?',
    options: [
      'a. La femme doit arrêter tout traitement avant d\'être enceinte',
      'b. La MICI doit être contrôlée',
      'c. Les femmes n\'ont pas besoin de discuter avec leur médecin avant de tomber enceinte',
      'd. Les femmes atteintes de MICI ne doivent pas arrêter de fumer',
    ],
    correctOptionIndex: 1,
    explanation:
        'L\'impératif médical absolu est que la MICI soit stabilisée en rémission clinique et biologique depuis au moins 3 à 6 mois avant la conception. Une poussée au moment de la conception ou pendant la grossesse multiplie les risques de fausse couche spontanée et de prématurité. Les traitements de fond compatibles doivent être poursuivis.',
    anatomicalTheme: 'Hérédité, Fertilité, Grossesse et Allaitement',
    ficheTitle: 'PLANIFICATION PRÉ-CONCEPTIONNELLE',
    fichePoints: [
      'Objectif fondamental : rémission clinique et biologique préalable à la conception.',
      'Ne jamais interrompre son traitement de fond sans concertation médicale.',
      'L\'arrêt du tabac est impératif, en particulier dans la maladie de Crohn.',
    ],
    whyOthersWrong:
        'Arrêter tout traitement déclenche des poussées dangereuses (a), une consultation pré-conceptionnelle est essentielle (c) et l\'arrêt du tabac reste impératif (d).',
    diagramType: 'pregnancy_care',
  ),
  const GastroQuestion(
    id: 21,
    worldId: 5,
    questionText: 'Les femmes atteintes de MICI :',
    options: [
      'a. Ne doivent jamais accoucher par césarienne',
      'b. Doivent accoucher par césarienne',
      'c. Peuvent accoucher par voie basse y compris en cas de lésions périnéales (fistule ou abcès anal)',
      'd. Peuvent accoucher par voie basse dans la plupart des cas',
    ],
    correctOptionIndex: 3,
    explanation:
        'L\'accouchement par voie basse est la modalité recommandée et possible dans la très grande majorité des cas. La césarienne programmée n\'est formellement indiquée qu\'en présence de lésions anopérinéales actives de maladie de Crohn (fistule ou abcès anal en cours) ou chez les patientes porteuses d\'une anastomose iléo-anale avec réservoir afin de préserver l\'appareil sphinctérien.',
    anatomicalTheme: 'Hérédité, Fertilité, Grossesse et Allaitement',
    ficheTitle: 'MODALITÉS D\'ACCOUCHEMENT',
    fichePoints: [
      'Voie basse autorisée et privilégiée dans la majorité des grossesses.',
      'Césarienne indiquée en cas de lésions anopérinéales actives (fistule/abcès anal).',
      'Césarienne également recommandée après anastomose iléo-anale avec réservoir.',
    ],
    whyOthersWrong:
        'La césarienne n\'est ni interdite (a) ni systématique (b), et la voie basse devient contre-indiquée en cas de lésions périnéales actives pour protéger le sphincter (c).',
    diagramType: 'pregnancy_care',
  ),
  const GastroQuestion(
    id: 22,
    worldId: 5,
    questionText: 'Une femme atteinte de MICI en poussée pendant la grossesse :',
    options: [
      'a. A habituellement un bébé plus grand et plus lourd que les autres femmes',
      'b. Accouche souvent un peu plus tôt',
      'c. Accouche souvent un peu plus tard',
      'd. Accouche toujours à terme même en cas de poussée de maladie de Crohn',
    ],
    correctOptionIndex: 1,
    explanation:
        'La survenue d\'une poussée inflammatoire active non contrôlée pendant la grossesse majore significativement le risque d\'accouchement prématuré (naissance avant 37 semaines d\'aménorrhée) et de faible poids de naissance (retard de croissance intra-utérin), d\'où l\'importance capitale du maintien du traitement protecteur.',
    anatomicalTheme: 'Hérédité, Fertilité, Grossesse et Allaitement',
    ficheTitle: 'POUSSÉE DURANT LA GROSSESSE',
    fichePoints: [
      'Une poussée non contrôlée majore le risque de prématurité.',
      'Risque accru de faible poids de naissance pour le nouveau-né.',
      'Le traitement médical adapté protège la santé du fœtus en éteignant l\'inflammation.',
    ],
    whyOthersWrong:
        'Une poussée inflammatoire expose au contraire à un petit poids de naissance plutôt qu\'à un gros bébé (a) et favorise la prématurité plutôt qu\'un dépassement de terme (c, d).',
    diagramType: 'pregnancy_care',
  ),
  const GastroQuestion(
    id: 23,
    worldId: 5,
    questionText:
        'Les malformations des nouveau-nés issus de patientes atteintes de MICI :',
    options: [
      'a. Sont fréquentes',
      'b. Sont plus fréquentes que dans la population générale',
      'c. Sont souvent dues aux effets secondaires des médicaments',
      'd. Peuvent être prévenues par la vaccination',
      'e. Aucune des réponses n\'est vraie',
    ],
    correctOptionIndex: 4,
    explanation:
        'Aucune des affirmations a, b, c ou d n\'est vraie. Le taux global de malformations congénitales chez les enfants de mères atteintes de MICI est superposable à celui de la population générale (de l\'ordre de 2 à 3 %). La plupart des thérapeutiques prescrites (5-ASA, corticoïdes, thiopurines, anti-TNF) n\'ont pas d\'effet tératogène avéré aux doses usuelles.',
    anatomicalTheme: 'Hérédité, Fertilité, Grossesse et Allaitement',
    ficheTitle: 'SANTÉ DU NOUVEAU-NÉ & TÉRATOGÉNICITÉ',
    fichePoints: [
      'Le taux de malformations congénitales n\'est pas supérieur à la population générale.',
      'Les traitements d\'entretien usuels (anti-TNF, dérivés salicylés) ne sont pas tératogènes.',
      'Seul le méthotrexate est formellement contre-indiqué (tératogène avéré).',
    ],
    whyOthersWrong:
        'Le taux de malformations reste identique à la population générale (a, b fausses), les traitements de fond habituels hors méthotrexate ne sont pas tératogènes (c) et la vaccination n\'est pas un facteur préventif de malformations (d).',
    diagramType: 'pregnancy_care',
  ),
  const GastroQuestion(
    id: 24,
    worldId: 5,
    questionText: 'Les mamans atteintes de MICI :',
    options: [
      'a. Ne doivent pas allaiter pour ne pas transmettre la maladie à leur enfant',
      'b. N\'ont jamais de poussée pendant l\'allaitement',
      'c. Peuvent avoir des petites quantités de médicaments dans leur lait maternel',
      'd. N\'ont pas besoin de discuter de l\'allaitement avec leur sage-femme ou leur médecin',
    ],
    correctOptionIndex: 2,
    explanation:
        'La grande majorité des médicaments utilisés dans les MICI (dérivés 5-ASA, corticoïdes, azathioprine, biothérapies anti-TNF) ne passent qu\'en très faibles quantités dans le lait maternel. Ces traces minimes sont considérées comme sans danger pour le nourrisson et ne contre-indiquent aucunement l\'allaitement maternel, qui doit être encouragé et supervisé par l\'équipe soignante.',
    anatomicalTheme: 'Hérédité, Fertilité, Grossesse et Allaitement',
    ficheTitle: 'ALLAITEMENT MATERNEL & TRAITEMENTS',
    fichePoints: [
      'Passage minime et sans danger de la plupart des molécules dans le lait maternel.',
      'Allaitement tout à fait possible sous 5-ASA, azathioprine et anti-TNF.',
      'Accompagnement soignant bienveillant pour sécuriser la décision de la jeune maman.',
    ],
    whyOthersWrong:
        'L\'allaitement ne transmet pas la MICI (a), des poussées post-partum peuvent survenir (b) et un échange avec l\'équipe médicale permet toujours de sécuriser le choix (d).',
    diagramType: 'breastfeeding_mici',
  ),

  // =========================================================================
  // MONDE 6 : Rôle Infirmier et Urgences MICI (Q25 à Q27)
  // =========================================================================
  const GastroQuestion(
    id: 25,
    worldId: 6,
    questionText:
        'Lors de la surveillance d\'un patient hospitalisé pour une poussée de rectocolite hémorragique (RCH), quel tableau clinique doit alerter l\'infirmier sur le risque d\'une colite aiguë grave nécessitant une prise en charge médico-chirurgicale urgente ?',
    options: [
      'a. Une diarrhée glairo-sanglante associée a une fiévre et une tachycardie',
      'b. Une douleur épigastrique soulagée par la prise d’aliments alcalins',
      'c. Une constipation opiniâtre associé à des ballonnement post prandiaux',
      'd. Une asthénie modérée associée à une sécheresse des muqueuses buccales',
    ],
    correctOptionIndex: 0,
    explanation:
        'Selon les critères de Truelove et Witts, la colite aiguë grave (CAG) est une urgence médico-chirurgicale absolue. Elle se manifeste par plus de 6 selles sanglantes par jour associées à des signes de toxicité systémique : fièvre > 37,8 °C, tachycardie > 90 bpm, anémie sévère (< 10,5 g/dL) et syndrome inflammatoire majeur (VS > 30 mm ou CRP élevée). Le risque vital immédiat est le mégacôlon toxique et la perforation colique.',
    anatomicalTheme: 'Rôle infirmière',
    ficheTitle: 'URGENCE : COLITE AIGUË GRAVE (CAG)',
    fichePoints: [
      'Signes d\'alerte : > 6 selles sanglantes/jour + tachycardie + fièvre + pâleur (anémie).',
      'Critères de Truelove-Witts : évaluation pronostique et décisionnelle immédiate.',
      'Risque majeur de perforation colique et de choc septique : alerte médicale sans délai.',
    ],
    whyOthersWrong:
        'La douleur ulcéreuse calmée par les aliments (b) évoque un ulcère gastrique ; une simple constipation avec ballonnements (c) ou une déshydratation buccale isolée (d) ne traduisent pas le choc toxinique de la CAG.',
    diagramType: 'emergency_nursing',
  ),
  const GastroQuestion(
    id: 26,
    worldId: 6,
    questionText:
        'Un patient est traité au long cours par azathioprine (Imurel) pour maintenir la rémission de sa MICI. Quelle surveillance biologique régulière l\'infirmier doit-il particulièrement contrôler pour dépister une toxicité médicamenteuse fréquente ?',
    options: [
      'a. La numération formule sanguin et le bilan hépatique',
      'b. La calcémie ionisée et le dosage de la TSH',
      'c. l’uricémie et le bilan lipidique complet a jeun',
      'd. La calcémie et la clairance de la créatinine plasmatique',
    ],
    correctOptionIndex: 0,
    explanation:
        'L\'azathioprine (Imurel) expose à deux toxicités prévisibles majeures nécessitant un suivi biologique strict et rapproché : la myélosuppression (leucopénie, neutropénie exposant aux infections sévères, anémie, thrombopénie) surveillée sur la NFS, et l\'hépatotoxicité (cytolyse hépatique avec élévation des transaminases) dépistée sur le bilan hépatique.',
    anatomicalTheme: 'Rôle infirmière',
    ficheTitle: 'SURVEILLANCE DE L\'AZATHIOPRINE (IMUREL)',
    fichePoints: [
      'NFS régulière : dépistage de la leucopénie et neutropénie (risque infectieux).',
      'Bilan hépatique (ASAT, ALAT, PAL, Bilirubine) : contrôle de la tolérance hépatique.',
      'Sensibilisation du patient aux signes d\'infection fébrile et à la photoprotection.',
    ],
    whyOthersWrong:
        'Calcémie/TSH (b), uricémie/bilan lipidique (c) ou créatinine isolée (d) ne ciblent pas les toxicités hématologique (myélosuppression) et hépatique propres aux thiopurines.',
    diagramType: 'emergency_nursing',
  ),
  const GastroQuestion(
    id: 27,
    worldId: 6,
    questionText:
        'Un patient est admis en hospitalisation pour une poussée sévère de rectocolite hémorragique avec émissions glairo-sanglantes fréquentes. La prescription médicale comporte une injection sous-cutanée quotidienne d\'énoxaparine (HBPM) à dose préventive. Quelle conduite l\'infirmier doit-il adopter ?',
    options: [
      'a. Diviser la dose prescrite par deux jusqu\'à la normalisation de la CRP',
      'b. Suspendre systématiquement l\'injection tant que persistent des rectorragies',
      'c. Remplacer l\'injection sous-cutanée par le port isolé de bas de contention',
      'd. Administrer l\'anticoagulant préventif tout en surveillant l\'abondance des saignements',
    ],
    correctOptionIndex: 3,
    explanation:
        'Les poussées sévères de MICI induisent un état d\'hypercoagulabilité majeur multipliant le risque de thrombose veineuse profonde et d\'embolie pulmonaire fatale. Malgré la présence de saignements digestifs extériorisés (rectorragies), l\'administration de l\'anticoagulant préventif par HBPM est formellement indiquée et indispensable. L\'infirmier doit administrer le traitement tout en surveillant rigoureusement la stabilité hémodynamique et l\'abondance des pertes sanguines.',
    anatomicalTheme: 'Rôle infirmière',
    ficheTitle: 'THROMBOPROPHYLAXIE EN HOSPITALISATION',
    fichePoints: [
      'Risque thromboembolique démultiplié au cours des poussées sévères de colite.',
      'L\'HBPM préventive est OBLIGATOIRE, même en présence de saignements digestifs.',
      'Rôle infirmier : administrer la dose prescrite et assurer une surveillance clinique étroite.',
    ],
    whyOthersWrong:
        'Réduire la dose (a), suspendre l\'HBPM sans avis (b) ou la remplacer par des bas seuls (c) exposerait le patient à une embolie pulmonaire grave due à l\'hypercoagulabilité.',
    diagramType: 'emergency_nursing',
  ),
];
