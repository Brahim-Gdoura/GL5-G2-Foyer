package tn.esprit.tpfoyer17.services;

import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import tn.esprit.tpfoyer17.entities.Chambre;
import tn.esprit.tpfoyer17.entities.enumerations.TypeChambre;
import tn.esprit.tpfoyer17.repositories.ChambreRepository;

import java.util.List;
import java.util.Optional;

@Service
@AllArgsConstructor
@Slf4j
@FieldDefaults(level = AccessLevel.PRIVATE)
public class ChambreService implements IChambreService{
    ChambreRepository chambreRepository;

    @Override
    public Chambre addChambre(Chambre chambre) {
        log.info("addChambre called with chambre={}", chambre);
        Chambre saved = chambreRepository.save(chambre);
        log.info("addChambre saved chambre={}", saved);
        return saved;


    }
    @Override
    public List<Chambre> getAllChambres() {
        log.info("getAllChambres called");
        List<Chambre> result = (List<Chambre>) chambreRepository.findAll();
        // findAll() from Spring Data returns an empty (non-null) List when there are no results,
        // so checking for null is unnecessary and the previous ternary was flagged as always false.
        log.info("getAllChambres returned {} items", result.size());
        if (log.isDebugEnabled()) log.debug("getAllChambres result={}", result);
        return result;
    }
    @Override
    public Chambre getChambreById(long idChambre) {
        log.info("getChambreById called with id={}", idChambre);
        Optional<Chambre> opt = chambreRepository.findById(idChambre);
        if (opt.isPresent()) {
            Chambre c = opt.get();
            log.info("getChambreById result={}", c);
            return c;
        } else {
            log.warn("getChambreById: no Chambre found with id={}", idChambre);
            return null;
        }
    }
    @Override
    public void deleteChambre(long idChambre) {
        log.info("deleteChambre called with id={}", idChambre);
        chambreRepository.deleteById(idChambre);
        log.info("deleteChambre completed for id={}", idChambre);
    }
    @Override
    public Chambre updateChambre(Chambre chambre) {
        log.info("updateChambre called with chambre={}", chambre);
        Chambre updated = chambreRepository.save(chambre);
        log.info("updateChambre updated chambre={}", updated);
        return updated;
    }

    @Override
    public List<Chambre> getChambresParNomUniversite(String nomUniversite) {
        log.info("getChambresParNomUniversite called with nomUniversite={}", nomUniversite);
        List<Chambre> result = chambreRepository.findByBlocFoyerUniversiteNomUniversite(nomUniversite);
        log.info("getChambresParNomUniversite returned {} items", result == null ? 0 : result.size());
        if (log.isDebugEnabled()) log.debug("getChambresParNomUniversite result={}", result);
        return result;
    }

    @Override
    public List<Chambre> getChambresParBlocEtTypeKeyWord(long idBloc, TypeChambre typeC) {
        log.info("getChambresParBlocEtTypeKeyWord called with idBloc={}, type={}", idBloc, typeC);
        List<Chambre> result = chambreRepository.findByBlocIdBlocAndTypeChambre(idBloc,typeC);
        log.info("getChambresParBlocEtTypeKeyWord returned {} items", result == null ? 0 : result.size());
        if (log.isDebugEnabled()) log.debug("getChambresParBlocEtTypeKeyWord result={}", result);
        return result;
    }

    @Override
    public List<Chambre> getChambresParBlocEtTypeJPQL(long idBloc, TypeChambre typeC) {
        log.info("getChambresParBlocEtTypeJPQL called with idBloc={}, type={}", idBloc, typeC);
        List<Chambre> result = chambreRepository.findByBlocIdBlocAndTypeChambreJPQL(idBloc,typeC);
        log.info("getChambresParBlocEtTypeJPQL returned {} items", result == null ? 0 : result.size());
        if (log.isDebugEnabled()) log.debug("getChambresParBlocEtTypeJPQL result={}", result);
        return result;
    }

    @Override
    public List<Chambre> getChambresNonReserveParNomUniversiteEtTypeChambre(String nomUniversite, TypeChambre type) {
        log.info("getChambresNonReserveParNomUniversiteEtTypeChambre called with nomUniversite={}, type={}", nomUniversite, type);
        List<Chambre> result = chambreRepository.getChambresNonReserveParNomUniversiteEtTypeChambre(nomUniversite,type);
        log.info("getChambresNonReserveParNomUniversiteEtTypeChambre returned {} items", result == null ? 0 : result.size());
        if (log.isDebugEnabled()) log.debug("getChambresNonReserveParNomUniversiteEtTypeChambre result={}", result);
        return result;
    }


    @Scheduled(cron = "*/30 * * * * * ")
    public void getChambreNonReserver(){
        try {
            List<Chambre> nonRes = chambreRepository.getChambresNonReserve();
            int count = nonRes == null ? 0 : nonRes.size();
            log.info("Scheduled getChambreNonReserver found {} non-reserved chambres", count);
            if (log.isDebugEnabled()) log.debug("Scheduled non-reserved chambres={}", nonRes);
        } catch (Exception e) {
            log.error("Scheduled getChambreNonReserver failed", e);
        }
    }

}
