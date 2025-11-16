package tn.esprit.tpfoyer17.etudiant;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import tn.esprit.tpfoyer17.entities.Etudiant;
import tn.esprit.tpfoyer17.repositories.EtudiantRepository;
import tn.esprit.tpfoyer17.services.EtudiantService;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

public class EtudiantServiceTest {

    @Mock
    EtudiantRepository etudiantRepository;

    @InjectMocks
    EtudiantService etudiantService;

    Etudiant etudiant1;
    Etudiant etudiant2;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
        etudiant1 = new Etudiant();
        etudiant1.setIdEtudiant(1L);
        etudiant1.setNomEtudiant("Ranya");
        etudiant1.setCinEtudiant(123456);

        etudiant2 = new Etudiant();
        etudiant2.setIdEtudiant(2L);
        etudiant2.setNomEtudiant("Asma");
        etudiant2.setCinEtudiant(654321);
    }

    @Test
    void testAddEtudiant() {
        when(etudiantRepository.save(etudiant1)).thenReturn(etudiant1);

        Etudiant saved = etudiantService.addEtudiant(etudiant1);
        assertNotNull(saved);
        assertEquals("Ranya", saved.getNomEtudiant());
    }

    @Test
    void testGetAllEtudiants() {
        when(etudiantRepository.findAll()).thenReturn(Arrays.asList(etudiant1, etudiant2));

        List<Etudiant> etudiants = etudiantService.getAllEtudiants();
        assertEquals(2, etudiants.size());
        verify(etudiantRepository, times(1)).findAll();
    }

    @Test
    void testGetEtudiantById() {
        when(etudiantRepository.findById(1L)).thenReturn(Optional.of(etudiant1));

        Etudiant found = etudiantService.getEtudiantById(1L);
        assertEquals("Ranya", found.getNomEtudiant());
    }

    @Test
    void testDeleteEtudiant() {
        doNothing().when(etudiantRepository).deleteById(1L);

        etudiantService.deleteEtudiant(1L);
        verify(etudiantRepository, times(1)).deleteById(1L);
    }

    @Test
    void testUpdateEtudiant() {
        when(etudiantRepository.save(etudiant1)).thenReturn(etudiant1);

        Etudiant updated = etudiantService.updateEtudiant(etudiant1);
        assertEquals("Ranya", updated.getNomEtudiant());
        verify(etudiantRepository, times(1)).save(etudiant1);
    }
}
