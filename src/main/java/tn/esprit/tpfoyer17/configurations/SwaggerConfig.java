package tn.esprit.tpfoyer17.configurations; // Adaptez le package selon votre structure

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class SwaggerConfig {

    @Bean
    public OpenAPI springShopOpenAPI() {
        return new OpenAPI()
                .info(new Info().title("TP Foyer API")
                        .description("TP Foyer 17 - Gestion des foyers")
                        .version("1.0.0")
                        .contact(new Contact().name("Votre Nom").email("votre.email@esprit.tn")));
    }
}