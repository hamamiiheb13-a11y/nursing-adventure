class GastroQuestion {
  final int id; // 1 to 30
  final int originalNumber; // Numéro d'origine dans le PDF (ex: 31, 32, 42, etc.)
  final int worldId; // 1 to 6
  final String questionText;
  final List<String> options;
  final int correctOptionIndex; // 0 for A, 1 for B, 2 for C, etc.
  final String explanation;
  final String anatomicalTheme;

  const GastroQuestion({
    required this.id,
    required this.originalNumber,
    required this.worldId,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
    required this.anatomicalTheme,
  });

  String get correctLetter {
    const letters = ['A', 'B', 'C', 'D', 'E'];
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

/// Les 30 questions du PDF intégrées strictement au mot près, sans aucune modification de texte.
final List<GastroQuestion> allGastroQuestions = [
  // ==========================================
  // MONDE 1 : Anatomie, Physiologie et Lésions Intestinales (4 questions)
  // ==========================================
  const GastroQuestion(
    id: 1,
    originalNumber: 31,
    worldId: 1,
    questionText: 'Question 31 : Une fistule :',
    options: [
      'A) Est un trajet anormal entre deux parties d\'intestin ou entre l\'intestin et la peau',
      'B) Est un rétrécissement de l\'intestin qui peut obstruer le passage de son contenu',
    ],
    correctOptionIndex: 0,
    explanation:
        'Une fistule est un conduit ou trajet anormal faisant communiquer deux cavités ou viscères creux entre eux (fistule entéro-entérique, entéro-colique, entéro-vésicale) ou reliant un segment intestinal à la surface cutanée (fistule entéro-cutanée ou ano-périnéale, fréquente dans la maladie de Crohn). À l\'inverse, un rétrécissement de la lumière intestinale correspond à une sténose.',
    anatomicalTheme: 'Lésions transmurales de la Maladie de Crohn',
  ),
  const GastroQuestion(
    id: 2,
    originalNumber: 32,
    worldId: 1,
    questionText: 'Question 32 : L\'iléon terminal :',
    options: [
      'A) Est la section d\'intestin juste avant l\'anus',
      'B) Est la section d\'intestin juste avant le colon',
    ],
    correctOptionIndex: 1,
    explanation:
        'L\'iléon terminal représente la dernière portion anatomique de l\'intestin grêle. Il s\'abouche dans le cæcum (première partie du côlon) au niveau de la valvule iléo-cæcale de Bauhin. C\'est le siège électif de l\'atteinte inflammatoire de la maladie de Crohn (iléite terminale). La section située juste avant l\'anus est le rectum.',
    anatomicalTheme: 'Intestin Grêle & Jonction Iléo-Cæcale',
  ),
  const GastroQuestion(
    id: 3,
    originalNumber: 42,
    worldId: 1,
    questionText: 'Question 42 : La fonction du colon est d\'absorber :',
    options: [
      'A) Des vitamines',
      'B) Des nutriments (sucres, graisses, protéines)',
      'C) De l\'eau',
    ],
    correctOptionIndex: 2,
    explanation:
        'La fonction physiologique prépondérante du côlon (gros intestin) est la réabsorption de l\'eau (environ 1,5 litre par 24 heures) et des électrolytes (sodium, chlore), permettant de concentrer et compacter le bol fécal. La quasi-totalité des nutriments (glucides, protides, lipides) et de la majorité des vitamines est absorbée en amont, au niveau de l\'intestin grêle.',
    anatomicalTheme: 'Physiologie de la Réabsorption Colique',
  ),
  const GastroQuestion(
    id: 4,
    originalNumber: 46,
    worldId: 1,
    questionText:
        'Question 46 : Il y a des millions de petits « replis » dans l\'intestin grêle qui augmentent la surface d\'absorption. Ils sont appelés :',
    options: [
      'A) Les villosités',
      'B) Les enzymes',
      'C) Les sels biliaires',
      'D) Les cryptes',
    ],
    correctOptionIndex: 0,
    explanation:
        'Les villosités intestinales sont de minuscules digitations de la muqueuse tapissant la paroi interne de l\'intestin grêle. Associées aux microvillosités des entérocytes, elles démultiplient la surface d\'échange jusqu\'à environ 250 m², optimisant le passage des nutriments vers la circulation sanguine et lymphatique.',
    anatomicalTheme: 'Architecture Muqueuse & Villosités',
  ),

  // ==========================================
  // MONDE 2 : Généralités, Symptômes et Manifestations de la Maladie (5 questions)
  // ==========================================
  const GastroQuestion(
    id: 5,
    originalNumber: 18,
    worldId: 2,
    questionText: 'Question 18 : La rémission clinique :',
    options: [
      'A) Signifie que le patient est guéri de sa MICI',
      'B) Signifie qu\'il n\'a plus de symptômes de sa maladie (ni diarrhées, ni sang dans les selles, ni douleurs abdominales...)',
      'C) Signifie que la coloscopie ne retrouve pas de lésions dans l\'intestin',
      'D) Signifie que le traitement doit être arrêté',
    ],
    correctOptionIndex: 1,
    explanation:
        'La rémission clinique correspond à la disparition complète des signes fonctionnels et symptômes digestifs ressentis par le patient (normalisation du transit, arrêt des saignements et des douleurs abdominales). Elle se distingue de la rémission biologique et endoscopique. Les MICI étant des maladies chroniques, la rémission clinique ne signifie ni guérison définitive ni interruption du traitement de fond.',
    anatomicalTheme: 'Évaluation Clinique & Objectifs de Rémission',
  ),
  const GastroQuestion(
    id: 6,
    originalNumber: 20,
    worldId: 2,
    questionText:
        'Question 20 : Un patient atteint de MICI a plus de risque d\'avoir, par rapport à la population générale :',
    options: [
      'A) Des douleurs articulaires',
      'B) Des maladies du cœur',
      'C) Des maladies des poumons',
      'D) Des maladies des reins',
    ],
    correctOptionIndex: 0,
    explanation:
        'Les atteintes ostéo-articulaires (rhumatismes périphériques, spondylarthrite ankylosante, sacro-iliites, enthésites) sont les manifestations extra-intestinales les plus fréquentes des MICI, touchant 20 % à 30 % des patients atteints de maladie de Crohn ou de rectocolite hémorragique.',
    anatomicalTheme: 'Manifestations Rhumatologiques & Extra-Digestives',
  ),
  const GastroQuestion(
    id: 7,
    originalNumber: 30,
    worldId: 2,
    questionText:
        'Question 30 : Les patients atteints de MICI peuvent développer de l\'inflammation dans d\'autres parties du corps autant que dans l\'intestin :',
    options: [
      'A) Vrai',
      'B) Faux',
    ],
    correctOptionIndex: 0,
    explanation:
        'Vrai. Les MICI sont des affections inflammatoires chroniques systémiques à médiation dysimmunitaire. L\'inflammation peut ainsi s\'exprimer au niveau des articulations, de la peau (érythème noueux, pyoderma gangrenosum), des yeux (uvéite, épisclérite) ou encore des voies biliaires (cholangite sclérosante primitive).',
    anatomicalTheme: 'Dimension Systémique des Pathologies Inflammatoires',
  ),
  const GastroQuestion(
    id: 8,
    originalNumber: 47,
    worldId: 2,
    questionText:
        'Question 47 : Parmi les propositions suivantes, laquelle n\'est pas un symptôme habituel des MICI :',
    options: [
      'A) Douleur abdominale',
      'B) Trouble du transit',
      'C) Céphalées',
      'D) Fièvre',
    ],
    correctOptionIndex: 2,
    explanation:
        'Les céphalées (maux de tête) ne constituent pas un signe clinique habituel ni un symptôme d\'alerte direct d\'une poussée de MICI. Les signes cardinaux associent les douleurs abdominales récurrentes, les troubles chroniques du transit (diarrhée glairo-sanglante), le syndrome rectal et, lors des poussées aiguës, un état fébrile ou un amaigrissement.',
    anatomicalTheme: 'Sémiologie Médicale des Poussées Aiguës',
  ),
  const GastroQuestion(
    id: 9,
    originalNumber: 48,
    worldId: 2,
    questionText:
        'Question 48 : Si un enfant est atteint de MICI, il ou elle ne pourra pas :',
    options: [
      'A) Vivre au-delà de 45 ans',
      'B) Être aussi grand que ses amis',
      'C) Suivre des études supérieures',
      'D) Toutes les réponses sont fausses',
    ],
    correctOptionIndex: 3,
    explanation:
        'Toutes les propositions A, B et C sont fausses. Grâce aux biothérapies précoces et à un accompagnement médical et nutritionnel adapté, un enfant atteint de MICI peut maîtriser l\'inflammation intestinale, préserver sa croissance staturale normale, accomplir des études supérieures sans entrave et bénéficier d\'une espérance de vie similaire à la population générale.',
    anatomicalTheme: 'MICI Pédiatriques & Pronostic Global',
  ),

  // ==========================================
  // MONDE 3 : Traitements Médicamenteux et Observance (5 questions)
  // ==========================================
  const GastroQuestion(
    id: 10,
    originalNumber: 5,
    worldId: 3,
    questionText: 'Question 5 : Les biothérapies anti-TNF :',
    options: [
      'A) Favorisent la survenue d\'un cancer du colon',
      'B) Ne favorisent pas la survenue des cancers « solides » (exemples : cancer du sein, de la prostate, du poumon...)',
      'C) Augmentent la survenue des cancers du sang ou des ganglions',
      'D) Sont systématiquement contre-indiquées chez les patients ayant déjà eu un cancer',
    ],
    correctOptionIndex: 1,
    explanation:
        'Les larges études de pharmacovigilance et les registres prospectifs démontrent que les anti-TNF en monothérapie ne majorent pas l\'incidence des cancers solides (sein, prostate, poumon). De surcroît, en cicatrisant la muqueuse et en éteignant l\'inflammation chronique colique, ils contribuent à réduire le risque de cancer colorectal lié à l\'inflammation.',
    anatomicalTheme: 'Sécurité Oncologique des Anti-TNF',
  ),
  const GastroQuestion(
    id: 11,
    originalNumber: 6,
    worldId: 3,
    questionText: 'Question 6 : Concernant les biothérapies anti-TNF :',
    options: [
      'A) L\'efficacité du traitement ne diminue jamais avec le temps',
      'B) Si l\'efficacité du traitement n\'est pas visible au bout d\'un mois, cela veut dire que le traitement ne fonctionne pas',
      'C) L\'efficacité du traitement peut être modulée par la prise simultanée d\'immunosuppresseurs',
      'D) Si l\'efficacité du traitement diminue, il faut nécessairement changer de traitement',
    ],
    correctOptionIndex: 2,
    explanation:
        'L\'association concomitante d\'un immunosuppresseur (tel que l\'azathioprine ou le méthotrexate) à une biothérapie anti-TNF (combothérapie) permet de prévenir l\'apparition d\'anticorps anti-médicaments (réduction de l\'immunogénicité) et améliore les concentrations sériques résiduelles, optimisant ainsi l\'efficacité thérapeutique.',
    anatomicalTheme: 'Combothérapie & Pharmacocinétique',
  ),
  const GastroQuestion(
    id: 12,
    originalNumber: 8,
    worldId: 3,
    questionText:
        'Question 8 : Les patients avec une MICI sous immunosuppresseurs :',
    options: [
      'A) Doivent éviter les lieux publics (transports en commun, supermarchés...) du fait du risque de développer une infection',
      'B) Doivent consulter régulièrement un dermatologue',
      'C) Ne doivent jamais s\'exposer au soleil (plage, montagne) y compris en cas d\'utilisation d\'un écran total',
      'D) Ne doivent plus réaliser de prise de sang de surveillance lorsque le traitement est poursuivi au-delà d\'un an',
    ],
    correctOptionIndex: 1,
    explanation:
        'Les immunosuppresseurs (notamment les thiopurines) augmentent modérément le risque de survenue de cancers cutanés non mélanomes (carcinomes épidermoïdes). Une consultation dermatologique annuelle systématique avec examen complet du tégument ainsi qu\'une photoprotection vigilante (écran total indice 50+, port de chapeau) sont formellement requises tout au long du traitement.',
    anatomicalTheme: 'Surveillance Dermatologique & Photoprotection',
  ),
  const GastroQuestion(
    id: 13,
    originalNumber: 10,
    worldId: 3,
    questionText:
        'Question 10 : Chez un patient atteint de MICI prenant un traitement au long cours :',
    options: [
      'A) La prise régulière du traitement n\'a pas de réelle influence sur son efficacité',
      'B) Il est possible d\'arrêter soi-même le médicament si les symptômes disparaissent et de le reprendre quand ils réapparaissent',
      'C) La prise irrégulière d\'un traitement anti-TNF peut entraîner une perte d\'efficacité de celui-ci',
      'D) La prise irrégulière du traitement par anti-TNF n\'accroît pas le risque de réactions allergiques',
    ],
    correctOptionIndex: 2,
    explanation:
        'L\'observance rigoureuse d\'un traitement anti-TNF est capitale. Les interruptions involontaires ou les prises décalées créent des creux pharmacologiques qui déclenchent la formation d\'anticorps neutralisants (immunisation). Ces anticorps entraînent une perte secondaire d\'efficacité et augmentent le risque d\'effets indésirables d\'hypersensibilité lors des réinjections.',
    anatomicalTheme: 'Observance & Prévention de l\'Immunisation',
  ),
  const GastroQuestion(
    id: 14,
    originalNumber: 11,
    worldId: 3,
    questionText:
        'Question 11 : Chez un patient avec une MICI traitée par immunosuppresseurs ou anti-TNF, et qui n\'a plus de symptômes (douleur, diarrhée, fatigue...) :',
    options: [
      'A) Il faut rapidement arrêter le traitement pour éviter les effets secondaires',
      'B) Le dosage des marqueurs inflammatoires (CRP, calprotectine, VS...) n\'intervient pas dans la décision d\'arrêter le traitement',
      'C) Une surveillance médicale régulière n\'est plus nécessaire',
      'D) La réalisation d\'une endoscopie (coloscopie...) ou d\'un examen d\'imagerie (entéro-IRM) est importante pour décider de l\'arrêt du traitement',
    ],
    correctOptionIndex: 3,
    explanation:
        'La disparition des plaintes fonctionnelles (rémission clinique) ne garantit pas la cicatrisation profonde de la muqueuse intestinale. Avant d\'envisager une éventuelle suspension ou désescalade thérapeutique, il est indispensable de confirmer la rémission endoscopique (ou par entéro-IRM) et la normalisation stricte des biomarqueurs (calprotectine, CRP) selon la stratégie "Treat to Target" afin d\'écarter tout risque de rechute précoce.',
    anatomicalTheme: 'Stratégie Treat-to-Target & Rémission Profonde',
  ),

  // ==========================================
  // MONDE 4 : Examens, Marqueurs Biologiques et Dépistage (4 questions)
  // ==========================================
  const GastroQuestion(
    id: 15,
    originalNumber: 14,
    worldId: 4,
    questionText:
        'Question 14 : Concernant le dosage de la CRP (Protéine C-réactive) :',
    options: [
      'A) Une CRP augmentée reflète toujours une MICI en poussée',
      'B) La CRP n\'est pas utile pour le suivi des MICI',
      'C) En l\'absence de symptôme, une CRP élevée sur plusieurs prises de sang consécutives doit faire réaliser d\'autres examens',
      'D) La CRP est plus fiable que la calprotectine fécale dans le cadre des MICI',
    ],
    correctOptionIndex: 2,
    explanation:
        'La CRP est un marqueur sensible d\'inflammation systémique. Une élévation persistante de la CRP chez un patient asymptomatique peut traduire une réactivation infraclinique de l\'inflammation intestinale (récidive biologique précédant la récidive symptomatique) ou une affection intercurrente, ce qui motive la réalisation d\'investigations complémentaires (calprotectine fécale, imagerie ou endoscopie).',
    anatomicalTheme: 'Protéine C-Réactive & Biologie Inflammatoire',
  ),
  const GastroQuestion(
    id: 16,
    originalNumber: 16,
    worldId: 4,
    questionText:
        'Question 16 : Chez un patient souffrant d\'une MICI touchant le colon, en l\'absence de symptôme (diarrhée, douleur, fatigue...), une coloscopie :',
    options: [
      'A) Devrait être toujours réalisée une fois par an',
      'B) N\'est jamais nécessaire sauf en cas de récidive des symptômes',
      'C) Permet de dépister des lésions précancéreuses dans le colon',
      'D) Ne doit être réalisée qu\'après 50 ans',
    ],
    correctOptionIndex: 2,
    explanation:
        'L\'inflammation muqueuse chronique au cours d\'une colite inflammatoire majore le risque de dysplasie et de cancer colorectal. Même en l\'absence totale de symptômes, des coloscopies de surveillance programmées (avec chromoendoscopie et biopsies ciblées) sont indispensables pour détecter et réséquer précocement d\'éventuelles lésions précancéreuses.',
    anatomicalTheme: 'Endoscopie Digestive & Dépistage de Dysplasie',
  ),
  const GastroQuestion(
    id: 17,
    originalNumber: 33,
    worldId: 4,
    questionText: 'Question 33 : Au cours d\'une poussée de MICI :',
    options: [
      'A) Le taux de plaquettes dans le sang augmente',
      'B) Le taux d\'albumine dans le sang augmente',
      'C) Le taux de globules blancs diminue',
    ],
    correctOptionIndex: 0,
    explanation:
        'Lors d\'une poussée active de MICI, la libération de cytokines pro-inflammatoires (telles que l\'IL-6) stimule la mégacaryopoïèse médullaire, provoquant une thrombocytose réactionnelle (augmentation du taux de plaquettes). Parallèlement, l\'albumine sérique a tendance à chuter (hypoalbuminémie) du fait du catabolisme accru et de la fuite entérique.',
    anatomicalTheme: 'Hématologie & Syndrome Inflammatoire Biologique',
  ),
  const GastroQuestion(
    id: 18,
    originalNumber: 45,
    worldId: 4,
    questionText:
        'Question 45 : Laquelle parmi les propositions suivantes est fausse concernant le dépistage du cancer du colon ? Un dépistage devrait être proposé à tous les patients atteints de rectocolite hémorragique :',
    options: [
      'A) Qui n\'affecte que le rectum',
      'B) Qui évolue depuis 8 - 10 ans',
      'C) Qui a débuté avant l\'âge de 50 ans',
    ],
    correctOptionIndex: 0,
    explanation:
        'La proposition A est fausse (et constitue donc la réponse exacte demandée) : une rectite ulcéreuse isolée (atteinte limitée au rectum) n\'augmente pas significativement le risque de cancer colorectal par rapport à la population générale et ne justifie pas de surveillance coloscopique dédiée. En revanche, les atteintes coliques étendues évoluant depuis 8 à 10 ans requièrent une surveillance systématique par chromoendoscopie.',
    anatomicalTheme: 'Recommandations Internationales de Dépistage',
  ),

  // ==========================================
  // MONDE 5 : Mode de vie, Alimentation et Voyages (4 questions)
  // ==========================================
  const GastroQuestion(
    id: 19,
    originalNumber: 3,
    worldId: 5,
    questionText:
        'Question 3 : Un patient souffrant de MICI, sous immunosuppresseurs ou sous biothérapie anti-TNF souhaite partir plusieurs semaines à l\'étranger :',
    options: [
      'A) Il est préférable de ne pas faire de voyage sous traitement',
      'B) Il faut arrêter le traitement pendant la durée du voyage et le reprendre au retour',
      'C) L\'accès à ces médicaments est assez facile à l\'étranger',
      'D) Un voyage est possible si celui-ci est anticipé et préparé en collaboration avec le médecin',
    ],
    correctOptionIndex: 3,
    explanation:
        'Voyager avec une MICI sous biothérapie ou immunosuppresseur est parfaitement réalisable moyennant une préparation rigoureuse : consultation pré-voyage, certificats médicaux bilingues pour le transport aérien, maintien de la chaîne du froid (2-8°C dans une sacoche isotherme), carnet vaccinal à jour (attention aux vaccins vivants atténués contre-indiqués) et ordonnance de secours.',
    anatomicalTheme: 'Médecine des Voyages & Chaîne du Froid',
  ),
  const GastroQuestion(
    id: 20,
    originalNumber: 12,
    worldId: 5,
    questionText: 'Question 12 : Chez un patient atteint de MICI :',
    options: [
      'A) L\'arrêt du tabac ne favorise pas la survenue d\'une poussée de RCH',
      'B) L\'arrêt du tabac peut favoriser la survenue d\'une poussée de maladie de Crohn',
      'C) Il est recommandé d\'arrêter de fumer chez tous les patients atteints de MICI',
      'D) Le tabac n\'augmente pas le risque d\'être opéré chez les patients souffrants de maladie de Crohn',
    ],
    correctOptionIndex: 2,
    explanation:
        'Le sevrage tabagique complet est universellement recommandé pour l\'ensemble des patients atteints de MICI en raison de ses bénéfices majeurs sur les plans cardiovasculaire, respiratoire et carcinologique. Dans la maladie de Crohn en particulier, le tabac est le facteur d\'aggravation principal, multipliant le risque de poussées, de rechutes et de résections chirurgicales.',
    anatomicalTheme: 'Tabacologie & Impact sur l\'Évolution des MICI',
  ),
  const GastroQuestion(
    id: 21,
    originalNumber: 23,
    worldId: 5,
    questionText: 'Question 23 : Les patients atteints de MICI :',
    options: [
      'A) Doivent éliminer le gluten de leur alimentation',
      'B) Doivent avoir une alimentation riche en sucres',
      'C) Doivent éliminer le lactose de leur alimentation',
      'D) Doivent avoir une alimentation la plus variée possible',
    ],
    correctOptionIndex: 3,
    explanation:
        'En période de rémission, les sociétés savantes (ECCO, ESPEN) recommandent une alimentation saine, diversifiée et équilibrée. Les régimes d\'exclusion systématique (sans gluten, sans produits laitiers) sans intolérance clinico-biologique démontrée ne sont pas justifiés et exposent inutilement les patients à des carences et à la dénutrition.',
    anatomicalTheme: 'Nutrition Clinique & Diversification Alimentaire',
  ),
  const GastroQuestion(
    id: 22,
    originalNumber: 26,
    worldId: 5,
    questionText:
        'Question 26 : Les produits alimentaires de nutrition artificielle entérale sont parfois utilisés pour traiter la maladie de Crohn ou la RCH. Ils :',
    options: [
      'A) Contiennent toujours beaucoup de fibres',
      'B) Sont très faciles à digérer',
      'C) Sont présentés sous formes de comprimés',
    ],
    correctOptionIndex: 1,
    explanation:
        'Les solutions nutritives entérales (formules liquides polymériques ou semi-élémentaires) sont dépourvues de fibres irritantes, hautement digestibles et rapidement absorbées au niveau de l\'intestin grêle proximal. La nutrition entérale exclusive constitue un traitement de première intention remarquable chez l\'enfant atteint de maladie de Crohn pour induire la rémission et relancer la croissance.',
    anatomicalTheme: 'Nutrition Entérale Thérapeutique',
  ),

  // ==========================================
  // MONDE 6 : Hérédité, Fertilité, Grossesse et Allaitement (8 questions)
  // ==========================================
  const GastroQuestion(
    id: 23,
    originalNumber: 29,
    worldId: 6,
    questionText: 'Question 29 : Les MICI peuvent être héréditaires :',
    options: [
      'A) Vrai',
      'B) Faux',
    ],
    correctOptionIndex: 0,
    explanation:
        'Vrai. Bien que les MICI ne soient pas des maladies monogéniques à transmission mendélienne simple, leur composante génétique et héréditaire est clairement établie : plus de 200 gènes de prédisposition ont été mis au jour (notamment NOD2/CARD15), et le risque d\'atteinte chez un apparenté au premier degré est multiplié par 5 à 10 par rapport à la population générale.',
    anatomicalTheme: 'Génétique & Prédisposition Familiale',
  ),
  const GastroQuestion(
    id: 24,
    originalNumber: 38,
    worldId: 6,
    questionText:
        'Question 38 : Si une femme est atteinte d\'une maladie de Crohn :',
    options: [
      'A) Elle peut avoir plus de difficultés pour être enceinte',
      'B) Elle ne devrait pas avoir d\'enfant',
      'C) Sa grossesse aura forcément des complications',
    ],
    correctOptionIndex: 0,
    explanation:
        'Une patiente atteinte de maladie de Crohn peut rencontrer plus de difficultés pour concevoir lorsque la maladie est en poussée active (altération de l\'axe gonadotrope par les cytokines) ou en cas d\'antécédents chirurgicaux abdomino-pelviens ayant provoqué des adhérences tubaires. En période de rémission stable sans séquelles chirurgicales, la fertilité est en revanche normale.',
    anatomicalTheme: 'Fertilité Féminine & Facteurs d\'Impact',
  ),
  const GastroQuestion(
    id: 25,
    originalNumber: 51,
    worldId: 6,
    questionText: 'Question 51 : Les hommes atteints de MICI :',
    options: [
      'A) N\'ont habituellement pas de problème d\'infertilité',
      'B) Devraient éviter tout médicament lorsqu\'ils essayent de concevoir un enfant',
      'C) Ne devraient pas avoir d\'enfant avec une femme atteinte de MICI',
      'D) Ne devraient pas avoir d\'enfant après 40 ans',
    ],
    correctOptionIndex: 0,
    explanation:
        'Chez l\'homme atteint de MICI, la fertilité est en règle générale conservée et comparable à celle de la population générale. Une exception notable concerne la sulfasalazine (Salazopyrine), pouvant engendrer une oligospermie réversible à l\'arrêt du produit. Les anti-TNF et la plupart des immunosuppresseurs n\'altèrent pas la fertilité masculine.',
    anatomicalTheme: 'Fertilité Masculine & Médicaments',
  ),
  const GastroQuestion(
    id: 26,
    originalNumber: 52,
    worldId: 6,
    questionText:
        'Question 52 : Qu\'est-ce qui est le plus important lorsqu\'on essaye d\'avoir un bébé ?',
    options: [
      'A) La femme doit arrêter tout traitement avant d\'être enceinte',
      'B) La MICI doit être contrôlée',
      'C) Les femmes n\'ont pas besoin de discuter avec leur médecin avant de tomber enceinte',
      'D) Les femmes atteintes de MICI ne doivent pas arrêter de fumer',
    ],
    correctOptionIndex: 1,
    explanation:
        'Le facteur déterminant majeur pour une gestation harmonieuse est d\'obtenir et de maintenir un contrôle parfait de la maladie : être en rémission clinique et biologique depuis au moins 3 à 6 mois au moment de la conception. Une poussée pendant la grossesse multiplie le risque de prématurité et de fausse couche spontanée. Le traitement compatible doit être impérativement poursuivi sous contrôle médical.',
    anatomicalTheme: 'Programmation de la Grossesse & Rémission Préconceptionnelle',
  ),
  const GastroQuestion(
    id: 27,
    originalNumber: 60,
    worldId: 6,
    questionText: 'Question 60 : Les femmes atteintes de MICI :',
    options: [
      'A) Ne doivent jamais accoucher par césarienne',
      'B) Doivent accoucher par césarienne',
      'C) Peuvent accoucher par voie basse y compris en cas de lésions périnéales (fistule ou abcès anal)',
      'D) Peuvent accoucher par voie basse dans la plupart des cas',
    ],
    correctOptionIndex: 3,
    explanation:
        'L\'accouchement par voie basse constitue la règle générale chez la patiente atteinte de MICI. La césarienne programmée n\'est indiquée que dans des situations très ciblées : présence de lésions anopérinéales actives (fistules, abcès) pour prémunir le sphincter anal contre toute déchirure obstétricale, ou antécédent d\'anastomose iléo-anale avec réservoir.',
    anatomicalTheme: 'Voie d\'Accouchement & Préservation Périnéale',
  ),
  const GastroQuestion(
    id: 28,
    originalNumber: 62,
    worldId: 6,
    questionText:
        'Question 62 : Une femme atteinte de MICI en poussée pendant la grossesse :',
    options: [
      'A) A habituellement un bébé plus grand et plus lourd que les autres femmes',
      'B) Accouche souvent un peu plus tôt',
      'C) Accouche souvent un peu plus tard',
      'D) Accouche toujours à terme même en cas de poussée de maladie de Crohn',
    ],
    correctOptionIndex: 1,
    explanation:
        'L\'activité inflammatoire non contrôlée au cours de la grossesse est le principal pourvoyeur de complications obstétricales, notamment de menace d\'accouchement prématuré (naissance avant 37 semaines d\'aménorrhée) et de retard de croissance intra-utérin. C\'est pourquoi il est fondamental de traiter efficacement toute poussée gravidique.',
    anatomicalTheme: 'Complications Obstétricales & Prématurité',
  ),
  const GastroQuestion(
    id: 29,
    originalNumber: 63,
    worldId: 6,
    questionText:
        'Question 63 : Les malformations des nouveau-nés issus de patientes atteintes de MICI :',
    options: [
      'A) Sont fréquentes',
      'B) Sont plus fréquentes que dans la population générale',
      'C) Sont souvent dues aux effets secondaires des médicaments',
      'D) Peuvent être prévenues par la vaccination',
      'E) Aucune des réponses n\'est vraie',
    ],
    correctOptionIndex: 4,
    explanation:
        'Le taux de malformations congénitales chez les enfants de patientes atteintes de MICI est strictement semblable à celui de la population générale (environ 2 à 3 %). Les thérapeutiques habituelles autorisées pendant la grossesse (anti-TNF, thiopurines, dérivés 5-ASA) ne sont pas tératogènes. Aucune des propositions A à D n\'étant exacte, la réponse correcte est bien E.',
    anatomicalTheme: 'Tératogénicité & Santé Périnatale',
  ),
  const GastroQuestion(
    id: 30,
    originalNumber: 65,
    worldId: 6,
    questionText: 'Question 65 : Les mamans atteintes de MICI :',
    options: [
      'A) Ne doivent pas allaiter pour ne pas transmettre la maladie à leur enfant',
      'B) N\'ont jamais de poussée pendant l\'allaitement',
      'C) Peuvent avoir des petites quantités de médicaments dans leur lait maternel',
      'D) N\'ont pas besoin de discuter de l\'allaitement avec leur sage-femme ou leur médecin',
    ],
    correctOptionIndex: 2,
    explanation:
        'D\'infimes concentrations de molécules thérapeutiques (tels les anticorps monoclonaux anti-TNF ou les dérivés de l\'azathioprine) peuvent passer dans le lait maternel. Toutefois, leur absorption digestive par le nourrisson est quasi-nulle et sans danger toxique documenté. L\'allaitement maternel est donc vivement recommandé et tout à fait compatible pour la majorité des patientes, sous suivi médical partagé.',
    anatomicalTheme: 'Allaitement Maternel & Passage Lacté',
  ),
];
