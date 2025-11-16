package tn.esprit.tpfoyer17.services;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import tn.esprit.tpfoyer17.entities.Chambre;
import tn.esprit.tpfoyer17.entities.enumerations.TypeChambre;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
public class ChambreServiceIntegrationTest {

    @Autowired
    IChambreService chambreService;

    @AfterEach
    public void cleanup() {
        // try to remove all chambres created during tests
        List<Chambre> all = chambreService.getAllChambres();
        if (all != null) {
            for (Chambre c : all) {
                try {
                    chambreService.deleteChambre(c.getIdChambre());
                } catch (Exception ignored) {}
            }
        }
    }

    @Test
    public void testAddChambre() {
        Chambre c = Chambre.builder()
                .numeroChambre(101)
                .typeChambre(TypeChambre.SIMPLE)
                .build();
        Chambre saved = chambreService.addChambre(c);
        assertNotNull(saved);
        assertTrue(saved.getIdChambre() > 0);
    }

    @Test
    public void testGetAllChambres() {
        Chambre c1 = Chambre.builder().numeroChambre(201).typeChambre(TypeChambre.DOUBLE).build();
        Chambre c2 = Chambre.builder().numeroChambre(202).typeChambre(TypeChambre.SIMPLE).build();
        chambreService.addChambre(c1);
        chambreService.addChambre(c2);

        List<Chambre> list = chambreService.getAllChambres();
        assertNotNull(list);
        assertTrue(list.size() >= 2);
    }

    @Test
    public void testUpdateChambre() {
        Chambre c = Chambre.builder().numeroChambre(301).typeChambre(TypeChambre.TRIPLE).build();
        Chambre saved = chambreService.addChambre(c);
        saved.setNumeroChambre(999);
        Chambre updated = chambreService.updateChambre(saved);
        assertEquals(999, updated.getNumeroChambre());
    }

    @Test
    public void testDeleteChambre() {
        Chambre c = Chambre.builder().numeroChambre(401).typeChambre(TypeChambre.SIMPLE).build();
        Chambre saved = chambreService.addChambre(c);
        long id = saved.getIdChambre();
        chambreService.deleteChambre(id);
        // after deletion, attempting to find should throw or return empty; use getAll to ensure it's gone
        List<Chambre> remaining = chambreService.getAllChambres();
        boolean contains = remaining.stream().anyMatch(ch -> ch.getIdChambre() == id);
        assertFalse(contains);
    }
}

