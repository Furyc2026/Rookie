class PotentialResult {
  final bool hasError;
  final String? errorMessage;
  final String? stromRange;
  final String? gasRange;
  final String? level;
  final String? reasoning;
  final List<String> hints;

  const PotentialResult({
    required this.hasError,
    this.errorMessage,
    this.stromRange,
    this.gasRange,
    this.level,
    this.reasoning,
    this.hints = const [],
  });
}

class PotentialService {
  static PotentialResult estimate({
    required String company,
    required String plz,
    required String branch,
  }) {
    final cleanedCompany = company.trim();
    final cleanedPlz = plz.trim();
    final normalizedBranch = branch.trim();

    if (cleanedCompany.isEmpty && cleanedPlz.isEmpty) {
      return const PotentialResult(
        hasError: true,
        errorMessage:
            'Bitte mindestens Firmenname und PLZ eingeben. Optional verbessert eine Branche die Einschätzung.',
        hints: [
          'Pflichtfelder: Firmenname + PLZ',
          'Optional: Branche für präzisere Bewertung',
          'Beispiel: Hotel Sonnenhof GmbH, 56068, Gesundheitswesen',
        ],
      );
    }

    if (cleanedCompany.isEmpty) {
      return const PotentialResult(
        hasError: true,
        errorMessage:
            'Der Firmenname fehlt. Ohne Unternehmensbezeichnung ist keine sinnvolle Einschätzung möglich.',
        hints: [
          'Bitte den vollständigen Firmennamen eingeben',
          'Rechtsformen wie GmbH, KG oder Holding helfen bei der Bewertung',
        ],
      );
    }

    if (cleanedPlz.isEmpty) {
      return const PotentialResult(
        hasError: true,
        errorMessage:
            'Die PLZ fehlt. Ohne Standort ist die Einschätzung zu ungenau.',
        hints: [
          'Bitte eine 5-stellige PLZ eingeben',
          'Die PLZ hilft bei der Einordnung von Standortgröße und Struktur',
        ],
      );
    }

    if (cleanedPlz.length != 5 || int.tryParse(cleanedPlz) == null) {
      return const PotentialResult(
        hasError: true,
        errorMessage: 'Die PLZ muss aus genau 5 Ziffern bestehen.',
        hints: [
          'Beispiel für gültige Eingabe: 20095',
        ],
      );
    }

    int stromBase = 25000;
    int gasBase = 5000;
    final reasons = <String>[];
    final hints = <String>[];

    final lowerCompany = cleanedCompany.toLowerCase();
    final lowerBranch = normalizedBranch.toLowerCase();

    if (cleanedCompany.length < 4) {
      return const PotentialResult(
        hasError: true,
        errorMessage:
            'Der Firmenname ist zu kurz für eine belastbare Einschätzung.',
        hints: [
          'Bitte möglichst die vollständige Firmierung eingeben',
          'Zusätze wie Gruppe, Holding, MVZ oder Hotel sind hilfreich',
        ],
      );
    }

    if (lowerCompany.contains('gmbh')) {
      stromBase += 15000;
      gasBase += 5000;
      reasons.add('Die Rechtsform deutet auf eine gewerbliche Struktur hin.');
    }

    if (lowerCompany.contains('gmbh & co. kg')) {
      stromBase += 25000;
      gasBase += 10000;
      reasons.add('Die Firmierung spricht eher für eine größere Unternehmensstruktur.');
    }

    if (lowerCompany.contains('gruppe') ||
        lowerCompany.contains('holding') ||
        lowerCompany.contains('beteiligungs') ||
        lowerCompany.contains('management')) {
      stromBase += 110000;
      gasBase += 35000;
      reasons.add('Der Firmenname deutet auf eine übergeordnete oder mehrgliedrige Struktur hin.');
      hints.add('Prüfen, ob mehrere Standorte oder Tochtergesellschaften gebündelt werden können.');
    }

    if (lowerCompany.contains('hotel') ||
        lowerCompany.contains('resort') ||
        lowerCompany.contains('spa')) {
      stromBase += 140000;
      gasBase += 160000;
      reasons.add('Hotellerie hat oft erhöhten Strom- und vor allem Wärmebedarf.');
      hints.add('Fragen nach Warmwasser, Küche, Wellness und Saisonlasten.');
    }

    if (lowerCompany.contains('pflege') ||
        lowerCompany.contains('senioren') ||
        lowerCompany.contains('klinik') ||
        lowerCompany.contains('krankenhaus') ||
        lowerCompany.contains('mvz') ||
        lowerCompany.contains('arzt')) {
      stromBase += 120000;
      gasBase += 50000;
      reasons.add('Gesundheitseinrichtungen haben häufig konstanten und planbaren Energiebedarf.');
      hints.add('Versorgungssicherheit und geringer interner Aufwand sind oft starke Argumente.');
    }

    if (lowerCompany.contains('zahn') ||
        lowerCompany.contains('dent') ||
        lowerCompany.contains('dental')) {
      stromBase += 35000;
      gasBase += 10000;
      reasons.add('Medizinische bzw. dentalnahe Nutzung spricht für regelmäßigen Grundverbrauch.');
    }

    if (lowerCompany.contains('fitness') ||
        lowerCompany.contains('gym') ||
        lowerCompany.contains('sport')) {
      stromBase += 60000;
      gasBase += 25000;
      reasons.add('Sport- und Fitnessbetriebe haben oft lange Öffnungszeiten und konstanten Strombedarf.');
      hints.add('Fragen nach Lüftung, Beleuchtung, Duschen und mehreren Standorten.');
    }

    if (lowerCompany.contains('markt') ||
        lowerCompany.contains('shop') ||
        lowerCompany.contains('store') ||
        lowerCompany.contains('filial') ||
        lowerCompany.contains('bäckerei') ||
        lowerCompany.contains('apotheke')) {
      stromBase += 70000;
      gasBase += 15000;
      reasons.add('Der Firmenname spricht für filialartige oder frequenzbasierte Nutzung.');
      hints.add('Unbedingt prüfen, ob mehrere Filialen in einem Bündel angesprochen werden können.');
    }

    if (lowerCompany.contains('industrie') ||
        lowerCompany.contains('produktion') ||
        lowerCompany.contains('werk') ||
        lowerCompany.contains('maschinenbau') ||
        lowerCompany.contains('metall') ||
        lowerCompany.contains('kunststoff') ||
        lowerCompany.contains('logistik')) {
      stromBase += 170000;
      gasBase += 90000;
      reasons.add('Die Firmenbezeichnung deutet auf energieintensivere gewerbliche Nutzung hin.');
      hints.add('Bei Industrie immer nach Lastspitzen, Schichtbetrieb und Prozesswärme fragen.');
    }

    if (lowerCompany.contains('immobilien') ||
        lowerCompany.contains('wohnen') ||
        lowerCompany.contains('wohnungs') ||
        lowerCompany.contains('hausverwaltung')) {
      stromBase += 50000;
      gasBase += 130000;
      reasons.add('Wohnungswirtschaft und Bestandshaltung haben oft relevantes Gas- und Bündelpotenzial.');
      hints.add('Fragen, ob zentral oder dezentral beheizt wird und wie viele Liegenschaften dazugehören.');
    }

    switch (normalizedBranch) {
      case 'Wohnungswirtschaft':
        stromBase += 40000;
        gasBase += 140000;
        reasons.add('Die gewählte Branche spricht für hohes Gaspotenzial und strukturelle Bündelung.');
        break;
      case 'Filialisten':
        stromBase += 110000;
        gasBase += 30000;
        reasons.add('Filialunternehmen haben oft verteilte Verbrauchsstellen mit Bündelpotenzial.');
        break;
      case 'Industrie':
        stromBase += 240000;
        gasBase += 180000;
        reasons.add('Industrie weist häufig hohen Bedarf und komplexere Beschaffungslogik auf.');
        break;
      case 'Gesundheitswesen':
        stromBase += 130000;
        gasBase += 50000;
        reasons.add('Im Gesundheitswesen sind Versorgungssicherheit und Stabilität meist besonders relevant.');
        break;
      default:
        if (lowerBranch.isNotEmpty) {
          reasons.add('Die Branche wurde berücksichtigt, ist aber noch nicht spezifisch in der Logik hinterlegt.');
        } else {
          hints.add('Mit Branchenauswahl wird die Einschätzung treffsicherer.');
        }
    }

    final plzPrefix = int.parse(cleanedPlz.substring(0, 2));

    if (plzPrefix >= 10 && plzPrefix <= 14) {
      stromBase += 10000;
      gasBase += 3000;
      reasons.add('Großraum-/Stadtlage kann auf größere Objekt- und Kundenstrukturen hindeuten.');
    } else if (plzPrefix >= 20 && plzPrefix <= 22) {
      stromBase += 15000;
      gasBase += 5000;
      reasons.add('Standort in einem wirtschaftlich starken Ballungsraum erhöht die Wahrscheinlichkeit größerer Strukturen.');
    } else if (plzPrefix >= 40 && plzPrefix <= 47) {
      stromBase += 12000;
      gasBase += 5000;
      reasons.add('Die Region spricht tendenziell für gewerbliche und industrielle Dichte.');
    } else if (plzPrefix >= 50 && plzPrefix <= 53) {
      stromBase += 6000;
      gasBase += 2000;
      reasons.add('Die Lage kann auf verdichtete gewerbliche Strukturen hindeuten.');
    }

    if (stromBase < 40000 && gasBase < 15000) {
      hints.add('Eher kleineres Potenzial – genauer prüfen, ob nur ein Einzelstandort vorliegt.');
    }

    final stromMin = stromBase;
    final stromMax = (stromBase * 1.8).round();
    final gasMin = gasBase;
    final gasMax = (gasBase * 1.8).round();

    final combinedBase = stromBase + gasBase;

    String level;
    if (combinedBase >= 450000) {
      level = 'HIGH';
    } else if (combinedBase >= 180000) {
      level = 'MID';
    } else {
      level = 'LOW';
    }

    if (level == 'HIGH') {
      hints.add('Potenziell priorisierter Lead – auf Entscheider, Bündelung und Vertragsstruktur gehen.');
    } else if (level == 'MID') {
      hints.add('Solider Lead – Bedarf und Anzahl der Abnahmestellen sauber qualifizieren.');
    } else {
      hints.add('Eher kleineres Potenzial – nur weiterverfolgen, wenn Zugang oder Multiplikator vorhanden ist.');
    }

    return PotentialResult(
      hasError: false,
      stromRange: '${_formatNumber(stromMin)} – ${_formatNumber(stromMax)} kWh',
      gasRange: '${_formatNumber(gasMin)} – ${_formatNumber(gasMax)} kWh',
      level: level,
      reasoning: reasons.isEmpty
          ? 'Die Einschätzung basiert aktuell hauptsächlich auf Firmenname, PLZ und Standardlogik.'
          : reasons.join(' '),
      hints: hints,
    );
  }

  static String _formatNumber(int number) {
    final raw = number.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < raw.length; i++) {
      buffer.write(raw[i]);
      final remaining = raw.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write('.');
      }
    }

    return buffer.toString();
  }
}