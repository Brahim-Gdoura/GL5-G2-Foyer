package tn.esprit.tpfoyer17.etudiant;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import tn.esprit.tpfoyer17.entities.Etudiant;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
public class EtudiantControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void testAddEtudiant() throws Exception {
        Etudiant e = Etudiant.builder()
                .nomEtudiant("TestController")
                .prenomEtudiant("User")
                .cinEtudiant(99998888L)
                .build();

        mockMvc.perform(post("/api/etudiants/add")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(e)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.nomEtudiant").value("TestController"));
    }

    @Test
    void testGetAllEtudiants() throws Exception {
        mockMvc.perform(get("/api/etudiants/getAll"))
                .andExpect(status().isOk())
                .andExpect(content().contentType("application/json"));
    }

    @Test
    void testGetEtudiantById() throws Exception {
        // Ajouter un étudiant
        Etudiant e = Etudiant.builder()
                .nomEtudiant("IDTest")
                .prenomEtudiant("User")
                .cinEtudiant(12312312L)
                .build();

        String res = mockMvc.perform(post("/api/etudiants/add")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(e)))
                .andReturn()
                .getResponse()
                .getContentAsString();

        Etudiant saved = objectMapper.readValue(res, Etudiant.class);

        // Test GET avec conversion correcte du long → String
        mockMvc.perform(get("/api/etudiants/get")
                        .param("idEtudiant", String.valueOf(saved.getIdEtudiant())))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.nomEtudiant").value("IDTest"));
    }

    @Test
    void testDeleteEtudiant() throws Exception {
        Etudiant e = Etudiant.builder()
                .nomEtudiant("DeleteController")
                .prenomEtudiant("User")
                .cinEtudiant(77776666L)
                .build();

        String res = mockMvc.perform(post("/api/etudiants/add")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(e)))
                .andReturn()
                .getResponse()
                .getContentAsString();

        Etudiant saved = objectMapper.readValue(res, Etudiant.class);

        mockMvc.perform(delete("/api/etudiants/delete/" + saved.getIdEtudiant()))
                .andExpect(status().isOk());
    }
}
