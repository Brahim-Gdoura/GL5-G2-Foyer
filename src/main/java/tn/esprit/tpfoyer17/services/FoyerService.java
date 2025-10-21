package tn.esprit.tpfoyer17.services;

import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import tn.esprit.tpfoyer17.entities.Foyer;
import tn.esprit.tpfoyer17.entities.Universite;
import tn.esprit.tpfoyer17.repositories.FoyerRepository;
import tn.esprit.tpfoyer17.repositories.UniversiteRepository;

import java.util.List;
import java.util.Optional;

@Service
@AllArgsConstructor
@Slf4j
@FieldDefaults(level = AccessLevel.PRIVATE)
public class FoyerService implements IFoyerService {
    FoyerRepository foyerRepository;
    UniversiteRepository universiteRepository;

    @Override
    public Foyer addFoyer(Foyer foyer) {
        log.info("Ajout d’un nouveau foyer : {}", foyer.getNomFoyer());
        Foyer savedFoyer = foyerRepository.save(foyer);
        log.info("Foyer ajouté avec succès : ID = {}", savedFoyer.getIdFoyer());
        return savedFoyer;
    }

    @Override
    public List<Foyer> getAllFoyers() {
        log.info("Récupération de la liste de tous les foyers");
        List<Foyer> foyers = (List<Foyer>) foyerRepository.findAll();
        log.info("Nombre total de foyers trouvés : {}", foyers.size());
        return foyers;
    }

    @Override
    public Foyer getFoyerById(long idFoyer) {
        log.info("Recherche du foyer avec ID : {}", idFoyer);
        Optional<Foyer> foyer = foyerRepository.findById(idFoyer);
        if (foyer.isPresent()) {
            log.info("Foyer trouvé : {}", foyer.get().getNomFoyer());
            return foyer.get();
        } else {
            log.warn("Aucun foyer trouvé avec l’ID : {}", idFoyer);
            return null;
        }
    }

    @Override
    public void deleteFoyer(long idFoyer) {
        log.info("Suppression du foyer avec ID : {}", idFoyer);
        foyerRepository.deleteById(idFoyer);
        log.info("Foyer supprimé avec succès !");
    }

    @Override
    public Foyer updateFoyer(Foyer foyer) {
        log.info("Mise à jour du foyer : ID = {}", foyer.getIdFoyer());
        Foyer updatedFoyer = foyerRepository.save(foyer);
        log.info("Foyer mis à jour avec succès : {}", updatedFoyer.getNomFoyer());
        return updatedFoyer;
    }

    @Override
    public Foyer ajouterFoyerEtAffecterAUniversite(Foyer foyer, long idUniversite) {
        log.info("Ajout d’un foyer et affectation à l’université ID = {}", idUniversite);
        Foyer foyer1 = foyerRepository.save(foyer);
        Universite universite = universiteRepository.findById(idUniversite).orElse(null);

        if (universite != null) {
            universite.setFoyer(foyer1);
            universiteRepository.save(universite);
            log.info("Foyer {} affecté à l’université {}", foyer1.getNomFoyer(), universite.getNomUniversite());
        } else {
            log.warn("Université avec ID = {} introuvable, affectation impossible", idUniversite);
        }

        return foyer1;
    }
}
