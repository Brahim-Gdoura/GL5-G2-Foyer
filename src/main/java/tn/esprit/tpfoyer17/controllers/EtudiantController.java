package tn.esprit.tpfoyer17.controllers;

import jakarta.validation.Valid;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import tn.esprit.tpfoyer17.entities.Etudiant;
import tn.esprit.tpfoyer17.repositories.EtudiantRepository;
import tn.esprit.tpfoyer17.services.IEtudiantService;

import java.util.List;

@RestController
@AllArgsConstructor
@Slf4j
@FieldDefaults(level = AccessLevel.PRIVATE)
@RequestMapping("api/etudiants")
public class EtudiantController {
    IEtudiantService etudiantService;
    EtudiantRepository etudiantRepository;

    // ========== ENDPOINTS EXISTANTS ==========

    @PostMapping("add")
    public Etudiant addEtudiant(@Valid @RequestBody Etudiant etudiant){
        return etudiantRepository.save(etudiant);
    }

    @GetMapping("getAll")
    public List<Etudiant> gettingAllEtudiant(){
        return etudiantService.getAllEtudiants();
    }

    @GetMapping("get")
    public Etudiant gettingEtudiant(@RequestParam("idEtudiant") long idEtudiant){
        return etudiantService.getEtudiantById(idEtudiant);
    }

    @DeleteMapping("delete/{idEtudiant}")
    public void deletingEtudiant(@PathVariable("idEtudiant") long idEtudiant){
        etudiantService.deleteEtudiant(idEtudiant);
    }

    @PutMapping("update")
    public Etudiant updatingEtudiant(@RequestBody Etudiant etudiant){
        return etudiantService.updateEtudiant(etudiant);
    }


    @GetMapping("search/cin/{cin}")
    public ResponseEntity<Etudiant> getEtudiantByCin(@PathVariable("cin") long cin){
        log.info("Recherche d'un étudiant avec CIN: {}", cin);
        Etudiant etudiant = etudiantRepository.findByCinEtudiant(cin);

        if (etudiant != null) {
            return ResponseEntity.ok(etudiant);
        } else {
            return ResponseEntity.notFound().build();
        }
    }


    @GetMapping("search/nom")
    public List<Etudiant> getEtudiantsByNom(@RequestParam("nom") String nom){
        log.info("Recherche des étudiants avec nom contenant: {}", nom);
        return etudiantRepository.findByNomEtudiantContainingIgnoreCase(nom);
    }


    @GetMapping("count")
    public ResponseEntity<Long> countEtudiants(){
        long count = etudiantRepository.count();
        log.info("Nombre total d'étudiants: {}", count);
        return ResponseEntity.ok(count);
    }


    @PostMapping("addMultiple")
    public ResponseEntity<List<Etudiant>> addMultipleEtudiants(@Valid @RequestBody List<Etudiant> etudiants){
        log.info("Ajout de {} étudiants", etudiants.size());
        List<Etudiant> savedEtudiants = etudiantRepository.saveAll(etudiants);
        return ResponseEntity.status(HttpStatus.CREATED).body(savedEtudiants);
    }


    @GetMapping("exists/{cin}")
    public ResponseEntity<Boolean> checkEtudiantExists(@PathVariable("cin") long cin){
        boolean exists = etudiantRepository.existsByCinEtudiant(cin);
        log.info("Vérification existence CIN {}: {}", cin, exists);
        return ResponseEntity.ok(exists);
    }
}