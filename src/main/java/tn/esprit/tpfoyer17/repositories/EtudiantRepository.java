package tn.esprit.tpfoyer17.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import tn.esprit.tpfoyer17.entities.Etudiant;

import java.util.List;

@Repository
public interface EtudiantRepository extends JpaRepository<Etudiant, Long> {

    // Rechercher un étudiant par CIN
    Etudiant findByCinEtudiant(long cin);

    // Rechercher des étudiants dont le nom contient une chaîne (insensible à la casse)
    List<Etudiant> findByNomEtudiantContainingIgnoreCase(String nom);

    // Vérifier si un étudiant existe avec ce CIN
    boolean existsByCinEtudiant(long cin);

    // Note: count() et saveAll() sont déjà fournis par JpaRepository
}
