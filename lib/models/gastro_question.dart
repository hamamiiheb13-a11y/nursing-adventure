class GastroQuestion {
  final int id; // 1 to 33
  final int worldId; // 1 to 7
  final String questionText;
  final List<String> options;
  final int correctOptionIndex; // 0 for a, 1 for b, 2 for c, etc.
  final String explanation;
  final String anatomicalTheme;
  final bool validated;

  const GastroQuestion({
    required this.id,
    required this.worldId,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
    required this.anatomicalTheme,
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

/// Les 33 questions exactes du PDF ISSIT - Projet de Fin d'Études (PFE)
/// Réparties dans les 7 mondes thématiques.
final List<GastroQuestion> allGastroQuestions = [
  // ==========================================
  // MONDE 1 : Anatomie, Physiologie et Lésions Intestinales (Q1 à Q4)
  // ==========================================
  const GastroQuestion(
    id: 1,
    worldId: 1,
    questionText: 'Q1 Une fistule :',
    options: [
      'a. Est un trajet anormal entre deux parties d\'intestin ou entre l\'intestin et la peau',
      'b. Est un rétrécissement de l\'intestin qui peut obstruer le passage de son contenu',
      'c. Je ne sais pas',
    ],
    correctOptionIndex: 0,
    explanation:
        'Une fistule est un conduit ou trajet anormal faisant communiquer deux cavités ou viscères creux entre eux (fistule entéro-entérique, entéro-colique, entéro-vésicale) ou reliant un segment intestinal à la surface cutanée (fistule entéro-cutanée ou ano-périnéale, fréquente dans la maladie de Crohn). À l\'inverse, un rétrécissement de la lumière intestinale correspond à une sténose.',
    anatomicalTheme: 'Anatomie, Physiologie et Lésions Intestinales',
    validated: true,
  ),
  const GastroQuestion(
    id: 2,
    worldId: 1,
    questionText:
        'Q2 Il y a des millions de petits « replis » dans l\'intestin grêle qui augmentent la surface d\'absorption. Ils sont appelés :',
    options: [
      'a. Les villosités',
      'b. Les enzymes',
      'c. Les sels biliaires',
      'd. Les cryptes',
      'e. Je ne sais pas',
    ],
    correctOptionIndex: 0,
    explanation:
        'Les villosités intestinales sont de minuscules digitations de la muqueuse tapissant la paroi interne de l\'intestin grêle. Associées aux microvillosités des entérocytes, elles démultiplient la surface d\'échange jusqu\'à environ 250 m², optimisant le passage des nutriments vers la circulation sanguine et lymphatique.',
    anatomicalTheme: 'Anatomie, Physiologie et Lésions Intestinales',
    validated: true,
  ),
  const GastroQuestion(
    id: 3,
    worldId: 1,
    questionText: 'Q3 La fonction du colon est d\'absorber :',
    options: [
      'a. Des vitamines',
      'b. Des nutriments (sucres, graisses, protéines)',
      'c. De l\'eau',
      'd. Je ne sais pas',
    ],
    correctOptionIndex: 2,
    explanation:
        'La fonction physiologique prépondérante du côlon (gros intestin) est la réabsorption de l\'eau (environ 1,5 litre par 24 heures) et des électrolytes (sodium, chlore), permettant de compacter le bol fécal. La quasi-totalité des nutriments (glucides, protides, lipides) est absorbée en amont dans l\'intestin grêle.',
    anatomicalTheme: 'Anatomie, Physiologie et Lésions Intestinales',
    validated: true,
  ),
  const GastroQuestion(
    id: 4,
    worldId: 1,
    questionText: 'Q4 L\'iléon terminal :',
    options: [
      'a. Est la section d\'intestin juste avant l\'anus',
      'b. Est la section d\'intestin juste avant le colon',
      'c. Je ne sais pas',
    ],
    correctOptionIndex: 1,
    explanation:
        'L\'iléon terminal représente la dernière portion anatomique de l\'intestin grêle. Il s\'abouche dans le cæcum (première partie du côlon) au niveau de la valvule iléo-cæcale de Bauhin. C\'est le siège électif de l\'atteinte inflammatoire de la maladie de Crohn (iléite terminale). La section située juste avant l\'anus est le rectum.',
    anatomicalTheme: 'Anatomie, Physiologie et Lésions Intestinales',
    validated: true,
  ),

  // ==========================================
  // MONDE 2 : Généralités, Symptômes et Manifestations de la Maladie (Q5 à Q9)
  // ==========================================
  const GastroQuestion(
    id: 5,
    worldId: 2,
    questionText: 'Q5 Si un enfant est atteint de MICI, il ou elle ne pourra pas :',
    options: [
      'a. Vivre au-delà de 45 ans',
      'b. Être aussi grand que ses amis',
      'c. Suivre des études supérieures',
      'd. Toutes les réponses sont fausses',
      'e. Je ne sais pas',
    ],
    correctOptionIndex: 3,
    explanation:
        'Toutes ces affirmations sont fausses : avec une prise en charge médicale contemporaine adaptée, l\'espérance de vie des enfants atteints de MICI est similaire à celle de la population générale. Un contrôle rapide de l\'inflammation permet de préserver la croissance staturo-pondérale et de poursuivre normalement des études supérieures.',
    anatomicalTheme: 'Généralités, Symptômes et Manifestations de la Maladie',
    validated: true,
  ),
  const GastroQuestion(
    id: 6,
    worldId: 2,
    questionText:
        'Q6 Un patient atteint de MICI a plus de risque d\'avoir, par rapport à la population générale :',
    options: [
      'a. Des douleurs articulaires',
      'b. Des maladies du cœur',
      'c. Des maladies des poumons',
      'd. Des maladies des reins',
      'e. Je ne sais pas',
    ],
    correctOptionIndex: 0,
    explanation:
        'Les manifestations extra-digestives les plus fréquentes au cours des MICI sont d\'ordre rhumatologique (touchant 20 à 30 % des patients) : arthralgies périphériques inflammatoires, enthésites et spondylarthropathies axiales associées au terrain génétique HLA-B27.',
    anatomicalTheme: 'Généralités, Symptômes et Manifestations de la Maladie',
    validated: true,
  ),
  const GastroQuestion(
    id: 7,
    worldId: 2,
    questionText: 'Q7 La rémission clinique :',
    options: [
      'a. Signifie que le patient est guéri de sa MICI',
      'b. Signifie qu\'il n\'a plus de symptômes de sa maladie (ni diarrhées, ni sang dans les selles, ni douleurs abdominales...)',
      'c. Signifie que la coloscopie ne retrouve pas de lésions dans l\'intestin',
      'd. Signifie que le traitement doit être arrêté',
      'e. Je ne sais pas',
    ],
    correctOptionIndex: 1,
    explanation:
        'La rémission clinique correspond à la disparition complète des signes fonctionnels et symptômes digestifs ressentis par le patient. Les MICI étant des affections inflammatoires chroniques, la rémission clinique ne signifie ni guérison définitive ni interruption du traitement de fond.',
    anatomicalTheme: 'Généralités, Symptômes et Manifestations de la Maladie',
    validated: true,
  ),
  const GastroQuestion(
    id: 8,
    worldId: 2,
    questionText:
        'Q8 Parmi les propositions suivantes, laquelle n\'est pas un symptôme habituel des MICI :',
    options: [
      'a. Douleur abdominale',
      'b. Trouble du transit',
      'c. Céphalées',
      'd. Fièvre',
      'e. Je ne sais pas',
    ],
    correctOptionIndex: 2,
    explanation:
        'Les céphalées isolées ne constituent pas un symptôme habituel des MICI. Le tableau clinique classique est dominé par des douleurs abdominales récurrentes, des troubles du transit (diarrhée glairo-sanglante chronique), une altération de l\'état général et parfois un fébricule lors des poussées aiguës.',
    anatomicalTheme: 'Généralités, Symptômes et Manifestations de la Maladie',
    validated: true,
  ),
  const GastroQuestion(
    id: 9,
    worldId: 2,
    questionText:
        'Q9 Les patients atteints de MICI peuvent développer de l\'inflammation dans d\'autres parties du corps autant que dans l\'intestin :',
    options: [
      'a. Vrai',
      'b. Faux',
    ],
    correctOptionIndex: 0,
    explanation:
        'Vrai : Les MICI sont des maladies inflammatoires dysimmunitaires systémiques. L\'inflammation peut toucher les articulations (arthrites, spondylarthrite), la peau (érythème noueux, pyoderma gangrenosum), les yeux (uvéite, épisclérite) et les voies biliaires (cholangite sclérosante primitive).',
    anatomicalTheme: 'Généralités, Symptômes et Manifestations de la Maladie',
    validated: true,
  ),

  // ==========================================
  // MONDE 3 : Traitements Médicamenteux et Observance (Q10 à Q14)
  // ==========================================
  const GastroQuestion(
    id: 10,
    worldId: 3,
    questionText: 'Q10 Les biothérapies anti-TNF :',
    options: [
      'a. Favorisent la survenue d\'un cancer du colon',
      'b. Ne favorisent pas la survenue des cancers « solides » (ex : cancer du sein, de la prostate, du poumon...)',
      'c. Augmentent la survenue des cancers du sang ou des ganglions',
      'd. Sont systématiquement contre-indiquées chez les patients ayant déjà eu un cancer',
      'e. Je ne sais pas',
    ],
    correctOptionIndex: 1,
    explanation:
        'Les données pharmaco-épidémiologiques de grande ampleur démontrent que les anti-TNF n\'augmentent pas l\'incidence des tumeurs d\'organes solides (sein, prostate, poumon...). Au contraire, en éteignant l\'inflammation chronique colique, ils contribuent à réduire le risque de cancer colorectal dysplasique.',
    anatomicalTheme: 'Traitements Médicamenteux et Observance',
    validated: true,
  ),
  const GastroQuestion(
    id: 11,
    worldId: 3,
    questionText: 'Q11 Concernant les biothérapies anti-TNF :',
    options: [
      'a. L\'efficacité du traitement ne diminue jamais avec le temps',
      'b. Si l\'efficacité du traitement n\'est pas visible au bout d\'un mois, cela veut dire que le traitement ne fonctionne pas',
      'c. L\'efficacité du traitement peut être modulée par la prise simultanée d\'immunosuppresseurs',
      'd. Si l\'efficacité du traitement diminue, il faut nécessairement changer de traitement',
      'e. Je ne sais pas',
    ],
    correctOptionIndex: 2,
    explanation:
        'L\'association thérapeutique synergique d\'un anti-TNF avec un immunosuppresseur (comme l\'azathioprine en combo-thérapie) réduit la formation d\'anticorps anti-médicament (immunisation) et majore les concentrations circulantes de l\'anticorps monoclonal, optimisant son efficacité au long cours.',
    anatomicalTheme: 'Traitements Médicamenteux et Observance',
    validated: true,
  ),
  const GastroQuestion(
    id: 12,
    worldId: 3,
    questionText: 'Q12 Les patients avec une MICI sous immunosuppresseurs :',
    options: [
      'a. Doivent éviter les lieux publics (transports en commun, supermarchés...) du fait du risque de développer une infection',
      'b. Doivent consulter régulièrement un dermatologue',
      'c. Ne doivent jamais s\'exposer au soleil (plage, montagne) y compris en cas d\'utilisation d\'un écran total',
      'd. Ne doivent plus réaliser de prise de sang de surveillance lorsque le traitement est poursuivi au-delà d\'un an',
      'e. Je ne sais pas',
    ],
    correctOptionIndex: 1,
    explanation:
        'Les patients sous immunosuppresseurs (en particulier les thiopurines comme l\'azathioprine) présentent un sur-risque modéré de carcinomes cutanés non-mélanocytaires. Un dépistage dermatologique annuel régulier avec photoprotection rigoureuse est donc formellement recommandé.',
    anatomicalTheme: 'Traitements Médicamenteux et Observance',
    validated: true,
  ),
  const GastroQuestion(
    id: 13,
    worldId: 3,
    questionText:
        'Q13 Chez un patient atteint de MICI prenant un traitement au long cours :',
    options: [
      'a. La prise régulière du traitement n\'a pas de réelle influence sur son efficacité',
      'b. Il est possible d\'arrêter soi-même le médicament si les symptômes disparaissent et de le reprendre quand ils réapparaissent',
      'c. La prise irrégulière d\'un traitement anti-TNF peut entraîner une perte d\'efficacité de celui-ci',
      'd. La prise irrégulière du traitement par anti-TNF n\'accroît pas le risque de réactions allergiques',
      'e. Je ne sais pas',
    ],
    correctOptionIndex: 2,
    explanation:
        'Une mauvaise observance thérapeutique ou l\'espacement irrégulier des injections anti-TNF induit des creux sériques favorisant la synthèse d\'anticorps neutralisants anti-médicaments (ADA), entraînant une perte d\'efficacité secondaire et un sur-risque d\'accidents d\'hypersensibilité.',
    anatomicalTheme: 'Traitements Médicamenteux et Observance',
    validated: true,
  ),
  const GastroQuestion(
    id: 14,
    worldId: 3,
    questionText:
        'Q14 Chez un patient avec une MICI traitée par immunosuppresseurs ou anti-TNF, et qui n\'a plus de symptômes (douleur, diarrhée, fatigue...) :',
    options: [
      'a. Il faut rapidement arrêter le traitement pour éviter les effets secondaires',
      'b. Le dosage des marqueurs inflammatoires (CRP, calprotectine, VS...) n\'intervient pas dans la décision d\'arrêter le traitement',
      'c. Une surveillance médicale régulière n\'est plus nécessaire',
      'd. La réalisation d\'une endoscopie (coloscopie...) ou d\'un examen d\'imagerie (entéro-IRM) est importante pour décider de l\'arrêt du traitement',
      'e. Je ne sais pas',
    ],
    correctOptionIndex: 3,
    explanation:
        'La cicatrisation muqueuse objective (attestée par la coloscopie ou l\'entéro-IRM) et la normalisation des biomarqueurs sont indispensables avant d\'envisager une désescalade thérapeutique encadrée. Une rémission purement clinique sans cicatrisation muqueuse expose à une récidive précoce.',
    anatomicalTheme: 'Traitements Médicamenteux et Observance',
    validated: true,
  ),

  // ==========================================
  // MONDE 4 : Examens, Marqueurs Biologiques et Dépistage (Q15 à Q18)
  // ==========================================
  const GastroQuestion(
    id: 15,
    worldId: 4,
    questionText: 'Q15 Au cours d\'une poussée de MICI :',
    options: [
      'a. Le taux de plaquettes dans le sang augmente',
      'b. Le taux d\'albumine dans le sang augmente',
      'c. Le taux de globules blancs diminue',
      'd. Je ne sais pas',
    ],
    correctOptionIndex: 0,
    explanation:
        'Au cours d\'une poussée inflammatoire, la sécrétion hépatique de thrombopoïétine et de cytokines pro-inflammatoires (IL-6) entraîne une thrombocytose réactionnelle (augmentation des plaquettes) et une hyperleucocytose. L\'albumine sérique tend au contraire à baisser par fuite entérique et hypercatabolisme.',
    anatomicalTheme: 'Examens, Marqueurs Biologiques et Dépistage',
    validated: true,
  ),
  const GastroQuestion(
    id: 16,
    worldId: 4,
    questionText:
        'Q16 Chez un patient souffrant d\'une MICI touchant le colon, en l\'absence de symptôme (diarrhée, douleur, fatigue...), une coloscopie :',
    options: [
      'a. Devrait être toujours réalisée une fois par an',
      'b. N\'est jamais nécessaire sauf en cas de récidive des symptômes',
      'c. Permet de dépister des lésions précancéreuses dans le colon',
      'd. Ne doit être réalisée qu\'après 50 ans',
      'e. Je ne sais pas',
    ],
    correctOptionIndex: 2,
    explanation:
        'L\'inflammation colique prolongée sur plus de 8 à 10 ans augmente le risque de dysplasie et de cancer colorectal. Même en l\'absence totale de symptômes cliniques, une coloscopie régulière de dépistage avec chromoendoscopie et biopsies étagées est indispensable pour détecter précocement les lésions précancéreuses.',
    anatomicalTheme: 'Examens, Marqueurs Biologiques et Dépistage',
    validated: true,
  ),
  const GastroQuestion(
    id: 17,
    worldId: 4,
    questionText: 'Q17 Concernant le dosage de la CRP (Protéine C-réactive) :',
    options: [
      'a. Une CRP augmentée reflète toujours une MICI en poussée',
      'b. La CRP n\'est pas utile pour le suivi des MICI',
      'c. En l\'absence de symptôme, une CRP élevée sur plusieurs prises de sang consécutives doit faire réaliser d\'autres examens',
      'd. La CRP est plus fiable que la calprotectine fécale dans le cadre des MICI',
      'e. Je ne sais pas',
    ],
    correctOptionIndex: 2,
    explanation:
        'Une élévation réitérée de la CRP en l\'absence de signes fonctionnels ressentis peut révéler une poussée infraclinique débutante ou une complication septique, justifiant la réalisation d\'examens complémentaires (calprotectine fécale, imagerie ou endoscopie).',
    anatomicalTheme: 'Examens, Marqueurs Biologiques et Dépistage',
    validated: true,
  ),
  const GastroQuestion(
    id: 18,
    worldId: 4,
    questionText:
        'Q18 Laquelle parmi les propositions suivantes est fausse concernant le dépistage du cancer du colon ? Un dépistage devrait être proposé à tous les patients atteints de rectocolite hémorragique :',
    options: [
      'a. Qui n\'affecte que le rectum',
      'b. Qui évolue depuis 8 - 10 ans',
      'c. Qui a débuté avant l\'âge de 50 ans',
      'd. Je ne sais pas',
    ],
    correctOptionIndex: 0,
    explanation:
        'La proposition fausse est la a : les rectites pures (atteinte limitée au rectum) n\'augmentent pas le risque de cancer colorectal par rapport à la population générale. Le dépistage systématique par chromoendoscopie s\'adresse aux colites gauches et pancolites évoluant depuis au moins 8 à 10 ans.',
    anatomicalTheme: 'Examens, Marqueurs Biologiques et Dépistage',
    validated: true,
  ),

  // ==========================================
  // MONDE 5 : Mode de vie, Alimentation et Voyages (Q19 à Q22)
  // ==========================================
  const GastroQuestion(
    id: 19,
    worldId: 5,
    questionText:
        'Q19 Un patient souffrant de MICI, sous immunosuppresseurs ou sous biothérapie anti-TNF souhaite partir plusieurs semaines à l\'étranger :',
    options: [
      'a. Il est préférable de ne pas faire de voyage sous traitement',
      'b. pendant la durée du voyage et le reprendre au retour',
      'c. L\'accès à ces médicaments est assez facile à l\'étranger',
      'd. Un voyage est possible si celui-ci est anticipé et préparé en collaboration avec le médecin',
      'e. Je ne sais pas',
    ],
    correctOptionIndex: 3,
    explanation:
        'Voyager est tout à fait compatible avec une MICI bien contrôlée. Le voyage doit être anticipé : vérification des vaccinations (contre-indication stricte des vaccins vivants atténués sous biothérapie/immunosuppresseurs), chaîne du froid pour les biomédicaments, ordonnances bilingues et trousse médicale de secours.',
    anatomicalTheme: 'Mode de vie, Alimentation et Voyages',
    validated: true,
  ),
  const GastroQuestion(
    id: 20,
    worldId: 5,
    questionText: 'Q20 Chez un patient atteint de MICI :',
    options: [
      'a. L\'arrêt du tabac ne favorise pas la survenue d\'une poussée de RCH',
      'b. L\'arrêt du tabac peut favoriser la survenue d\'une poussée de maladie de Crohn',
      'c. Il est recommandé d\'arrêter de fumer chez tous les patients atteints de MICI',
      'd. Le tabac n\'augmente pas le risque d\'être opéré chez les patients souffrants de maladie de Crohn',
      'e. Je ne sais pas',
    ],
    correctOptionIndex: 2,
    explanation:
        'Le sevrage tabagique absolu est recommandé pour tous les patients atteints de MICI. Dans la maladie de Crohn, le tabac est un facteur aggravant majeur multipliant les poussées, les fistules et les résections chirurgicales. Même si l\'arrêt peut parfois démasquer une poussée de RCH, le bénéfice cardiovasculaire et carcinologique reste prioritaire.',
    anatomicalTheme: 'Mode de vie, Alimentation et Voyages',
    validated: true,
  ),
  const GastroQuestion(
    id: 21,
    worldId: 5,
    questionText: 'Q21 Les patients atteints de MICI :',
    options: [
      'a. Doivent éliminer le gluten de leur alimentation',
      'b. Doivent avoir une alimentation riche en sucres',
      'c. Doivent éliminer le lactose de leur alimentation',
      'd. Doivent avoir une alimentation la plus variée possible',
      'e. Je ne sais pas',
    ],
    correctOptionIndex: 3,
    explanation:
        'Hors période de poussée aiguë où un régime d\'épargne digestive peut être transitoirement indiqué, il est recommandé de maintenir une alimentation variée et équilibrée afin de prévenir les carences en micronutriments et la dénutrition. Aucun régime d\'exclusion systématique (sans gluten, sans lactose) n\'est justifié sans intolérance avérée.',
    anatomicalTheme: 'Mode de vie, Alimentation et Voyages',
    validated: true,
  ),
  const GastroQuestion(
    id: 22,
    worldId: 5,
    questionText:
        'Q22 Les produits alimentaires de nutrition artificielle entérale sont parfois utilisés pour traiter la maladie de Crohn ou la RCH. Ils :',
    options: [
      'a. Contiennent toujours beaucoup de fibres',
      'b. Sont très faciles à digérer',
      'c. Sont présentés sous formes de comprimés',
      'd. Je ne sais pas',
    ],
    correctOptionIndex: 1,
    explanation:
        'Les solutés de nutrition entérale sont des formules nutritives liquides polymériques ou semi-élémentaires spécialement équilibrées et conçues pour être très digestes et rapidement résorbées dans le grêle, permettant de mettre l\'intestin au repos tout en restaurant l\'état nutritionnel.',
    anatomicalTheme: 'Mode de vie, Alimentation et Voyages',
    validated: true,
  ),

  // ==========================================
  // MONDE 6 : Hérédité, Fertilité, Grossesse et Allaitement (Q23 à Q30)
  // ==========================================
  const GastroQuestion(
    id: 23,
    worldId: 6,
    questionText: 'Q23 Les MICI peuvent être héréditaires :',
    options: [
      'a. Vrai',
      'b. Faux',
    ],
    correctOptionIndex: 0,
    explanation:
        'Vrai : Il existe une prédisposition génétique bien démontrée (plus de 200 gènes de susceptibilité identifiés, comme NOD2/CARD15 pour la maladie de Crohn). Cependant, il ne s\'agit pas d\'une transmission mendélienne directe : les facteurs environnementaux et le microbiote sont indispensables au déclenchement.',
    anatomicalTheme: 'Hérédité, Fertilité, Grossesse et Allaitement',
    validated: true,
  ),
  const GastroQuestion(
    id: 24,
    worldId: 6,
    questionText: 'Q24 Si une femme est atteinte d\'une maladie de Crohn :',
    options: [
      'a. Elle peut avoir plus de difficultés pour être enceinte',
      'b. Elle ne devrait pas avoir d\'enfant',
      'c. Sa grossesse aura forcément des complications',
      'd. Je ne sais pas',
    ],
    correctOptionIndex: 0,
    explanation:
        'La fertilité féminine est strictement normale lorsque la maladie de Crohn est en rémission. En revanche, la fertilité peut être temporairement diminuée en période de poussée inflammatoire active ou à la suite de chirurgies abdomino-pelviennes compliquées d\'adhérences tubaires.',
    anatomicalTheme: 'Hérédité, Fertilité, Grossesse et Allaitement',
    validated: true,
  ),
  const GastroQuestion(
    id: 25,
    worldId: 6,
    questionText: 'Q25 Les hommes atteints de MICI :',
    options: [
      'a. N\'ont habituellement pas de problème d\'infertilité',
      'b. Devraient éviter tout médicament lorsqu\'ils essayent de concevoir un enfant',
      'c. Ne devraient pas avoir d\'enfant avec une femme atteinte de MICI',
      'd. Ne devraient pas avoir d\'enfant après 40 ans',
      'e. Je ne sais pas',
    ],
    correctOptionIndex: 0,
    explanation:
        'La fertilité masculine n\'est généralement pas altérée par la maladie en période de rémission. Seule la sulfasalazine (Salazopyrine) peut entraîner une altération réversible de la spermatogenèse qui régresse 2 à 3 mois après arrêt ou relais par un dérivé 5-ASA pur.',
    anatomicalTheme: 'Hérédité, Fertilité, Grossesse et Allaitement',
    validated: true,
  ),
  const GastroQuestion(
    id: 26,
    worldId: 6,
    questionText:
        'Q26 Qu\'est-ce qui est le plus important lorsqu\'on essaye d\'avoir un bébé ?',
    options: [
      'a. La femme doit arrêter tout traitement avant d\'être enceinte',
      'b. La MICI doit être contrôlée',
      'c. Les femmes n\'ont pas besoin de discuter avec leur médecin avant de tomber enceinte',
      'd. Les femmes atteintes de MICI ne doivent pas arrêter de fumer',
      'e. Je ne sais pas',
    ],
    correctOptionIndex: 1,
    explanation:
        'Le facteur prépondérant conditionnant le déroulement favorable de la grossesse est la conception en période de rémission clinique et biologique stable depuis au moins 3 à 6 mois. La poursuite du traitement de fond d\'entretien est indispensable pour éviter une rechute gravidique.',
    anatomicalTheme: 'Hérédité, Fertilité, Grossesse et Allaitement',
    validated: true,
  ),
  const GastroQuestion(
    id: 27,
    worldId: 6,
    questionText: 'Q27 Les femmes atteintes de MICI :',
    options: [
      'a. Ne doivent jamais accoucher par césarienne',
      'b. Doivent accoucher par césarienne',
      'c. Peuvent accoucher par voie basse y compris en cas de lésions périnéales (fistule ou abcès anal)',
      'd. Peuvent accoucher par voie basse dans la plupart des cas',
      'e. Je ne sais pas',
    ],
    correctOptionIndex: 3,
    explanation:
        'L\'accouchement par voie basse naturelle est possible et recommandé pour la très grande majorité des patientes. La césarienne élective n\'est formellement indiquée qu\'en cas de lésions anopérinéales actives ou antécédents d\'anastomose iléo-anale, afin d\'éviter un traumatisme sphinctérien.',
    anatomicalTheme: 'Hérédité, Fertilité, Grossesse et Allaitement',
    validated: true,
  ),
  const GastroQuestion(
    id: 28,
    worldId: 6,
    questionText:
        'Q28 Une femme atteinte de MICI en poussée pendant la grossesse :',
    options: [
      'a. A habituellement un bébé plus grand et plus lourd que les autres femmes',
      'b. Accouche souvent un peu plus tôt',
      'c. Accouche souvent un peu plus tard',
      'd. Accouche toujours à terme même en cas de poussée de maladie de Crohn',
      'e. Je ne sais pas',
    ],
    correctOptionIndex: 1,
    explanation:
        'L\'activité inflammatoire non contrôlée au cours de la grossesse est le principal pourvoyeur de complications obstétricales, notamment de menace d\'accouchement prématuré (naissance avant 37 semaines d\'aménorrhée) et de retard de croissance intra-utérin.',
    anatomicalTheme: 'Hérédité, Fertilité, Grossesse et Allaitement',
    validated: true,
  ),
  const GastroQuestion(
    id: 29,
    worldId: 6,
    questionText:
        'Q29 Les malformations des nouveau-nés issus de patientes atteintes de MICI :',
    options: [
      'a. Sont fréquentes',
      'b. Sont plus fréquentes que dans la population générale',
      'c. Sont souvent dues aux effets secondaires des médicaments',
      'd. Peuvent être prévenues par la vaccination',
      'e. Aucune des réponses n\'est vraie',
    ],
    correctOptionIndex: 4,
    explanation:
        'Le taux de malformations congénitales chez les enfants de patientes atteintes de MICI est strictement semblable à celui de la population générale (environ 2 à 3 %). Les thérapeutiques habituelles autorisées pendant la grossesse (anti-TNF, thiopurines, dérivés 5-ASA) ne sont pas tératogènes. Aucune des propositions a à d n\'étant exacte, la réponse est e.',
    anatomicalTheme: 'Hérédité, Fertilité, Grossesse et Allaitement',
    validated: true,
  ),
  const GastroQuestion(
    id: 30,
    worldId: 6,
    questionText: 'Q30 Les mamans atteintes de MICI :',
    options: [
      'a. Ne doivent pas allaiter pour ne pas transmettre la maladie à leur enfant',
      'b. N\'ont jamais de poussée pendant l\'allaitement',
      'c. Peuvent avoir des petites quantités de médicaments dans leur lait maternel',
      'd. N\'ont pas besoin de discuter de l\'allaitement avec leur sage-femme ou leur médecin',
      'e. Je ne sais pas',
    ],
    correctOptionIndex: 2,
    explanation:
        'D\'infimes concentrations de molécules thérapeutiques (comme les anticorps monoclonaux anti-TNF ou les métabolites de l\'azathioprine) peuvent passer dans le lait maternel. Toutefois, leur absorption digestive par le nourrisson est négligeable et sans danger toxique documenté. L\'allaitement maternel est donc tout à fait compatible et encouragé.',
    anatomicalTheme: 'Hérédité, Fertilité, Grossesse et Allaitement',
    validated: true,
  ),

  // ==========================================
  // MONDE 7 : Rôle infirmière (Q31 à Q33)
  // ==========================================
  const GastroQuestion(
    id: 31,
    worldId: 7,
    questionText:
        'Q31 Lors de la surveillance d\'un patient hospitalisé pour une poussée de rectocolite hémorragique (RCH), quel tableau clinique doit alerter l\'infirmier sur le risque d\'une colite aiguë grave nécessitant une prise en charge médico-chirurgicale urgente ?',
    options: [
      'a. Une diarrhée glairo-sanglante associée a une fiévre et une tachycardie',
      'b. Une douleur épigastrique soulagée par la prise d’aliments alcalins',
      'c. Une constipation opiniâtre associé à des ballonnement post prandiaux',
      'd. Une asthénie modérée associée à une sécheresse des muqueuses buccales',
    ],
    correctOptionIndex: 0,
    explanation:
        'Les critères de Truelove et Witts définissant la colite aiguë grave (CAG) associent au moins 6 émissions sanglantes quotidiennes avec des signes d\'altération systémique : fièvre > 37,8°C, tachycardie > 90 bpm, anémie (hémoglobine < 10,5 g/dL) et syndrome inflammatoire (VS > 30 mm ou CRP > 45 mg/L). C\'est une urgence médico-chirurgicale absolue imposant un monitorage rapproché du risque de mégacôlon toxique et de perforation.',
    anatomicalTheme: 'Rôle infirmière & Urgences MICI',
    validated: true,
  ),
  const GastroQuestion(
    id: 32,
    worldId: 7,
    questionText:
        'Q32 Un patient est traité au long cours par azathioprine (Imurel) pour maintenir la rémission de sa MICI. Quelle surveillance biologique régulière l\'infirmier doit-il particulièrement contrôler pour dépister une toxicité médicamenteuse fréquente ?',
    options: [
      'a. La numération formule sanguin et le bilan hépatique',
      'b. La calcémie ionisée et le dosage de la TSH',
      'c. l’uricémie et le bilan lipidique complet a jeun',
      'd. La calcémie et la clairance de la créatinine plasmatique',
    ],
    correctOptionIndex: 0,
    explanation:
        'L\'azathioprine (thiopurine) expose à deux risques majeurs de toxicité précoce et tardive : la myélosuppression (neutropénie, anémie, thrombopénie par aplasie médullaire) et l\'hépatotoxicité (cytolyse ou cholestase hépatique). L\'infirmier doit donc s\'assurer du contrôle régulier de la NFS (hémogramme) et des enzymes hépatiques (ALAT/ASAT, bilirubine, phosphatases alcalines).',
    anatomicalTheme: 'Rôle infirmière & Toxicité Médicamenteuse',
    validated: true,
  ),
  const GastroQuestion(
    id: 33,
    worldId: 7,
    questionText:
        'Q33 Un patient est admis en hospitalisation pour une poussée sévère de rectocolite hémorragique avec émissions glairo-sanglantes fréquentes. La prescription médicale comporte une injection sous-cutanée quotidienne d\'énoxaparine (HBPM) à dose préventive. Quelle conduite l\'infirmier doit-il adopter ?',
    options: [
      'a. Diviser la dose prescrite par deux jusqu\'à la normalisation de la CRP',
      'b. Suspendre systématiquement l\'injection tant que persistent des rectorragies',
      'c. Remplacer l\'injection sous-cutanée par le port isolé de bas de contention',
      'd. Administrer l\'anticoagulant préventif tout en surveillant l\'abondance des saignements',
    ],
    correctOptionIndex: 3,
    explanation:
        'Toute poussée sévère de MICI constitue un puissant état pro-thrombotique (multipliant par 3 à 4 le risque de thrombose veineuse profonde et d\'embolie pulmonaire). Les recommandations internationales et françaises stipulent formellement que l\'anticoagulation préventive par HBPM doit être maintenue systématiquement malgré les rectorragies actives, tout en surveillant la tolérance hémodynamique.',
    anatomicalTheme: 'Rôle infirmière & Thromboembolisme en Poussée',
    validated: true,
  ),
];
