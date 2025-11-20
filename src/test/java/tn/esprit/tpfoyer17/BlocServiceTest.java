    package tn.esprit.tpfoyer17;

    import org.junit.jupiter.api.Test;
    import org.springframework.beans.factory.annotation.Autowired;
    import org.springframework.boot.test.context.SpringBootTest;
    import org.springframework.test.context.ActiveProfiles;
    import tn.esprit.tpfoyer17.entities.Bloc;
    import tn.esprit.tpfoyer17.services.IBlocService;

    import static org.junit.jupiter.api.Assertions.*;

    @SpringBootTest
    @ActiveProfiles("test")
    public class BlocServiceTest {

        @Autowired
        IBlocService blocService;

        @Test
        public void testAddBloc() {
            Bloc bloc = new Bloc();
            bloc.setNomBloc("Bloc Test");
            bloc.setCapaciteBloc(50);

            Bloc savedBloc = blocService.addBloc(bloc);
            assertNotNull(savedBloc.getIdBloc());
            assertEquals("Bloc Test", savedBloc.getNomBloc());

            blocService.deleteBloc(savedBloc.getIdBloc()); // nettoyage
        }

        @Test
        public void testGetBlocById() {
            Bloc bloc = new Bloc();
            bloc.setNomBloc("Bloc GetById");
            bloc.setCapaciteBloc(30);
            Bloc savedBloc = blocService.addBloc(bloc);

            Bloc fetchedBloc = blocService.getBlocById(savedBloc.getIdBloc());
            assertEquals(savedBloc.getNomBloc(), fetchedBloc.getNomBloc());

            blocService.deleteBloc(savedBloc.getIdBloc());
        }

        @Test
        public void testUpdateBloc() {
            Bloc bloc = new Bloc();
            bloc.setNomBloc("Bloc Update");
            bloc.setCapaciteBloc(20);
            Bloc savedBloc = blocService.addBloc(bloc);

            savedBloc.setNomBloc("Bloc Updated");
            Bloc updatedBloc = blocService.updateBloc(savedBloc);
            assertEquals("Bloc Updated", updatedBloc.getNomBloc());

            blocService.deleteBloc(savedBloc.getIdBloc());
        }

        @Test
        public void testDeleteBloc() {
            Bloc bloc = new Bloc();
            bloc.setNomBloc("Bloc Delete");
            bloc.setCapaciteBloc(10);
            Bloc savedBloc = blocService.addBloc(bloc);

            blocService.deleteBloc(savedBloc.getIdBloc());
            assertThrows(Exception.class, () -> blocService.getBlocById(savedBloc.getIdBloc()));
        }
    }
