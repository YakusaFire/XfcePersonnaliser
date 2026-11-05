#version 330
// fond-anime : pendant le fond animé, le fond de xfdesktop est une couleur unie, la couleur
// moyenne de la vidéo (posée par fond-anime-fond). Ce shader rend transparents les pixels
// de cette couleur, lue sur le bord droit du bureau : la vidéo, placée dessous, apparaît
// derrière les icônes, dont les bords et l'ombre des noms se fondent dans la vidéo.
// picom ne l'applique que pendant le fond animé (propriété _FOND_ANIME du bureau).
in vec2 texcoord;
uniform sampler2D tex;

vec3 pixel(ivec2 p) {
    return texelFetch(tex, p, 0).rgb;
}

vec4 window_shader() {
    ivec2 taille = textureSize(tex, 0);
    vec3 bas = pixel(taille - 1);
    vec3 haut = pixel(ivec2(taille.x - 1, 0));
    vec3 milieu = pixel(ivec2(taille.x - 1, taille.y / 2));
    // Couleur de fond : celle d'au moins deux des trois points (une icône peut en cacher un)
    vec3 cle = (distance(bas, haut) < 0.002 || distance(bas, milieu) < 0.002) ? bas : haut;
    vec3 c = pixel(ivec2(texcoord));
    if (all(lessThan(abs(c - cle), vec3(0.5 / 255.0))))
        return vec4(0.0);
    return vec4(c, 1.0);
}
