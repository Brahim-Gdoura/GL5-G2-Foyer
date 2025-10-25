package tn.esprit.tpfoyer17;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import tn.esprit.tpfoyer17.entities.Foyer;
import tn.esprit.tpfoyer17.services.IFoyerService;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
public class FoyerServiceTest {

    @Autowired
    IFoyerService foyerService;

    // ✅ Test: Add Foyer
    @Test
    public void testAddFoyer() {
        Foyer foyer = new Foyer();
        foyer.setNomFoyer("Foyer Test");
        foyer.setCapaciteFoyer(300L);

        Foyer savedFoyer = foyerService.addFoyer(foyer);

        assertNotNull(savedFoyer.getIdFoyer());
        assertEquals("Foyer Test", savedFoyer.getNomFoyer());
        assertEquals(300L, savedFoyer.getCapaciteFoyer());

        foyerService.deleteFoyer(savedFoyer.getIdFoyer()); // nettoyage
    }

    // ✅ Test: Get Foyer By ID
    @Test
    public void testGetFoyerById() {
        Foyer foyer = new Foyer();
        foyer.setNomFoyer("Foyer GetById");
        foyer.setCapaciteFoyer(200L);
        Foyer savedFoyer = foyerService.addFoyer(foyer);

        Foyer fetchedFoyer = foyerService.getFoyerById(savedFoyer.getIdFoyer());
        assertNotNull(fetchedFoyer);
        assertEquals(savedFoyer.getNomFoyer(), fetchedFoyer.getNomFoyer());
        assertEquals(savedFoyer.getCapaciteFoyer(), fetchedFoyer.getCapaciteFoyer());

        foyerService.deleteFoyer(savedFoyer.getIdFoyer());
    }

    // ✅ Test: Update Foyer
    @Test
    public void testUpdateFoyer() {
        Foyer foyer = new Foyer();
        foyer.setNomFoyer("Foyer Update");
        foyer.setCapaciteFoyer(120L);
        Foyer savedFoyer = foyerService.addFoyer(foyer);

        savedFoyer.setNomFoyer("Foyer Updated");
        savedFoyer.setCapaciteFoyer(150L);
        Foyer updatedFoyer = foyerService.updateFoyer(savedFoyer);

        assertEquals("Foyer Updated", updatedFoyer.getNomFoyer());
        assertEquals(150L, updatedFoyer.getCapaciteFoyer());

        foyerService.deleteFoyer(savedFoyer.getIdFoyer());
    }

    // ✅ Test: Delete Foyer
    @Test
    public void testDeleteFoyer() {
        Foyer foyer = new Foyer();
        foyer.setNomFoyer("Foyer Delete");
        foyer.setCapaciteFoyer(80L);
        Foyer savedFoyer = foyerService.addFoyer(foyer);

        foyerService.deleteFoyer(savedFoyer.getIdFoyer());

        Foyer deleted = foyerService.getFoyerById(savedFoyer.getIdFoyer());
        assertNull(deleted);
    }
}
