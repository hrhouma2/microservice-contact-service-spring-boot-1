# Architecture Flexible - Multi-Formulaires et Multi-Sites

## Table des Matieres

1. [Introduction - La Force de cette Architecture](#1-introduction-la-force-de-cette-architecture)
2. [Un Seul Backend pour Plusieurs Sites](#2-un-seul-backend-pour-plusieurs-sites)
3. [Plusieurs Formulaires par Site](#3-plusieurs-formulaires-par-site)
4. [Exemples d'Utilisation](#4-exemples-dutilisation)
5. [Configuration et Gestion](#5-configuration-et-gestion)
6. [Avantages de cette Architecture](#6-avantages-de-cette-architecture)
7. [Exemples de Code Frontend](#7-exemples-de-code-frontend)

---

## 1. Introduction - La Force de cette Architecture

### Qu'est-ce qui rend ce Contact Service special ?

Ce microservice a ete concu avec une **architecture flexible** qui permet :

✅ **Un seul backend** pour **plusieurs sites web**  
✅ **Plusieurs formulaires** sur **le meme site**  
✅ **Adaptation automatique** selon le contexte  
✅ **Gestion centralisee** de tous les messages  
✅ **Evolutivite** sans modification du backend  

### Le Secret : Le Champ `formId`

```json
{
  "formId": "contact-form-1",  // Identifiant unique du formulaire
  "email": "user@example.com"
}
```

Le champ `formId` permet de **differencier** :
- Les formulaires d'un meme site
- Les formulaires de sites differents
- Les types de demandes (contact, support, candidature, etc.)

---

## 2. Un Seul Backend pour Plusieurs Sites

### Schema d'Architecture

```
┌─────────────────────────────────────────────────────┐
│         Contact Service API (Port 8080)             │
│              PostgreSQL Database                     │
└──────────────────────┬──────────────────────────────┘
                       │
         ┌─────────────┼─────────────┐
         │             │             │
         ▼             ▼             ▼
┌────────────┐  ┌────────────┐  ┌────────────┐
│  Site Web  │  │  Site E-   │  │  Landing   │
│  Principal │  │  commerce  │  │   Page     │
│            │  │            │  │            │
│ - Contact  │  │ - Support  │  │ - Devis    │
│ - Devis    │  │ - Retour   │  │ - Demo     │
│ - Support  │  │ - Contact  │  │            │
└────────────┘  └────────────┘  └────────────┘
     ▲               ▲               ▲
     │               │               │
  localhost:3000  monsite.com    landing.com
```

### Exemple Concret

Vous avez **3 sites web differents** qui utilisent **la meme API** :

#### Site 1 : Site Corporate (`https://monentreprise.com`)
```javascript
// Formulaire de contact general
fetch('http://api.monentreprise.com:8080/api/contact', {
  method: 'POST',
  body: JSON.stringify({
    formId: 'corporate-contact',  // Identifiant unique
    email: 'client@example.com',
    pageUrl: 'https://monentreprise.com/contact'
  })
});
```

#### Site 2 : Boutique en ligne (`https://shop.monentreprise.com`)
```javascript
// Formulaire de support client
fetch('http://api.monentreprise.com:8080/api/contact', {
  method: 'POST',
  body: JSON.stringify({
    formId: 'shop-support',  // Identifiant different
    email: 'client@example.com',
    pageUrl: 'https://shop.monentreprise.com/support'
  })
});
```

#### Site 3 : Landing Page Marketing (`https://promo.monentreprise.com`)
```javascript
// Formulaire d'inscription newsletter
fetch('http://api.monentreprise.com:8080/api/contact', {
  method: 'POST',
  body: JSON.stringify({
    formId: 'promo-newsletter',  // Encore different
    email: 'prospect@example.com',
    pageUrl: 'https://promo.monentreprise.com/signup'
  })
});
```

### Resultat dans PostgreSQL

Tous les messages sont centralises mais **facilement identifiables** :

```sql
SELECT 
    id,
    email,
    message,
    -- Le formId permet de savoir d'ou vient le message
    CASE 
        WHEN form_id LIKE 'corporate-%' THEN 'Site Corporate'
        WHEN form_id LIKE 'shop-%' THEN 'Boutique'
        WHEN form_id LIKE 'promo-%' THEN 'Landing Page'
    END as origine,
    date_soumission
FROM contact_submissions
ORDER BY date_soumission DESC;
```

---

## 3. Plusieurs Formulaires par Site

### Cas d'Usage Reel

Un seul site peut avoir **plusieurs formulaires** pour differents besoins :

```
Site Web Principal (monsite.com)
├── Formulaire de Contact General     → formId: "site-contact"
├── Formulaire de Demande de Devis    → formId: "site-devis"
├── Formulaire de Support Technique   → formId: "site-support"
├── Formulaire de Recrutement         → formId: "site-rh"
├── Formulaire de Partenariat         → formId: "site-partenariat"
└── Formulaire de Newsletter          → formId: "site-newsletter"
```

### Exemple Implementation React

#### Composant Contact General

```jsx
// components/ContactForm.jsx
function ContactForm() {
  const handleSubmit = async (formData) => {
    await fetch('http://api.monsite.com:8080/api/contact', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        formId: 'site-contact',  // Formulaire contact
        email: formData.email,
        name: formData.name,
        message: formData.message
      })
    });
  };
  // ... reste du composant
}
```

#### Composant Demande de Devis

```jsx
// components/QuoteForm.jsx
function QuoteForm() {
  const handleSubmit = async (formData) => {
    await fetch('http://api.monsite.com:8080/api/contact', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        formId: 'site-devis',  // Formulaire devis
        email: formData.email,
        name: formData.name,
        data: {
          type_projet: formData.typeProjet,
          budget: formData.budget,
          delai: formData.delai
        }
      })
    });
  };
  // ... reste du composant
}
```

#### Composant Support Technique

```jsx
// components/SupportForm.jsx
function SupportForm() {
  const handleSubmit = async (formData) => {
    await fetch('http://api.monsite.com:8080/api/contact', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        formId: 'site-support',  // Formulaire support
        email: formData.email,
        name: formData.name,
        data: {
          numero_ticket: formData.ticketNumber,
          priorite: formData.priority,
          type_probleme: formData.issueType
        }
      })
    });
  };
  // ... reste du composant
}
```

---

## 4. Exemples d'Utilisation

### Exemple 1 : Agence Web avec Plusieurs Clients

Vous etes une agence qui gere **plusieurs sites pour differents clients** :

```javascript
// Client A - Restaurant
{
  "formId": "restaurant-reservation",
  "email": "client@example.com",
  "data": {
    "nb_personnes": 4,
    "date": "2025-12-01",
    "heure": "19:30"
  }
}

// Client B - Hotel
{
  "formId": "hotel-booking",
  "email": "client@example.com",
  "data": {
    "checkin": "2025-12-15",
    "checkout": "2025-12-20",
    "chambres": 2
  }
}

// Client C - E-commerce
{
  "formId": "shop-contact-vendeur",
  "email": "acheteur@example.com",
  "data": {
    "produit_id": "12345",
    "question": "Disponibilite en taille M ?"
  }
}
```

**Avantage** : Un seul backend a maintenir pour tous vos clients !

---

### Exemple 2 : Entreprise avec Ecosystem de Sites

Une entreprise avec plusieurs sites pour differents services :

#### Site Principal (Corporate)

```javascript
// Page Contact
{
  "formId": "corp-contact-general",
  "email": "prospect@example.com"
}

// Page Carrieres
{
  "formId": "corp-rh-candidature",
  "email": "candidat@example.com",
  "data": {
    "poste": "Developpeur Full Stack",
    "cv_url": "https://..."
  }
}

// Page Presse
{
  "formId": "corp-presse-demande",
  "email": "journaliste@media.com"
}
```

#### Plateforme E-learning

```javascript
// Inscription formation
{
  "formId": "elearning-inscription",
  "email": "etudiant@example.com",
  "data": {
    "formation": "Spring Boot Avance",
    "niveau": "intermediaire"
  }
}

// Support technique
{
  "formId": "elearning-support",
  "email": "etudiant@example.com",
  "data": {
    "cours_id": "SB-101",
    "probleme": "Video ne se charge pas"
  }
}
```

#### Application Mobile

```javascript
// Feedback in-app
{
  "formId": "mobile-feedback",
  "email": "user@example.com",
  "data": {
    "version_app": "2.1.3",
    "os": "iOS 17",
    "rating": 5
  }
}
```

---

### Exemple 3 : Startup en Croissance

Vous commencez avec **un seul formulaire**, puis vous evoluez :

#### Phase 1 : MVP (1 formulaire)

```javascript
{
  "formId": "mvp-contact",
  "email": "early-adopter@example.com"
}
```

#### Phase 2 : Croissance (3 formulaires)

```javascript
// Contact general
{ "formId": "v2-contact", ... }

// Support client
{ "formId": "v2-support", ... }

// Demande demo
{ "formId": "v2-demo", ... }
```

#### Phase 3 : Scale (10+ formulaires)

```javascript
// Contact
{ "formId": "v3-contact-sales", ... }
{ "formId": "v3-contact-support", ... }
{ "formId": "v3-contact-partnership", ... }

// Produits
{ "formId": "v3-product-enterprise", ... }
{ "formId": "v3-product-startup", ... }

// Events
{ "formId": "v3-event-webinar", ... }
{ "formId": "v3-event-conference", ... }

// RH
{ "formId": "v3-rh-candidature-dev", ... }
{ "formId": "v3-rh-candidature-sales", ... }
{ "formId": "v3-rh-stage", ... }
```

**Avantage** : Vous n'avez **JAMAIS** besoin de modifier le backend !

---

## 5. Configuration et Gestion

### Configuration CORS pour Multi-Sites

```env
# .env - Autoriser plusieurs domaines
CORS_ALLOWED_ORIGINS=https://site1.com,https://site2.com,https://shop.site1.com,https://blog.site2.com
```

### Statistiques par Site/Formulaire

```sql
-- Statistiques par formulaire
SELECT 
    -- Extraire le prefixe du formId (avant le tiret)
    SPLIT_PART(form_id, '-', 1) as site,
    COUNT(*) as nombre_messages,
    COUNT(*) FILTER (WHERE lu = false) as non_lus,
    MAX(date_soumission) as dernier_message
FROM contact_submissions
GROUP BY site
ORDER BY nombre_messages DESC;

-- Resultat :
-- site      | nombre_messages | non_lus | dernier_message
-- corporate | 1250           | 15      | 2025-11-23 10:30:00
-- shop      | 890            | 42      | 2025-11-23 10:25:00
-- promo     | 456            | 8       | 2025-11-23 10:15:00
```

### Filtrage dans PostgreSQL

```sql
-- Voir seulement les messages d'un site specifique
SELECT * FROM contact_submissions 
WHERE form_id LIKE 'corporate-%'
ORDER BY date_soumission DESC;

-- Voir seulement les demandes de devis
SELECT * FROM contact_submissions 
WHERE form_id LIKE '%-devis'
ORDER BY date_soumission DESC;

-- Voir seulement le support technique
SELECT * FROM contact_submissions 
WHERE form_id LIKE '%-support'
ORDER BY date_soumission DESC;
```

---

## 6. Avantages de cette Architecture

### Avantage 1 : Centralisation

✅ **Une seule base de donnees** pour tous les messages  
✅ **Un seul point d'administration**  
✅ **Statistiques globales** faciles  
✅ **Sauvegarde simplifiee**  

### Avantage 2 : Evolutivite

✅ **Nouveau site ?** → Nouveau `formId`, aucune modification backend  
✅ **Nouveau formulaire ?** → Nouveau `formId`, aucune modification backend  
✅ **Nouveau champ ?** → Utiliser `data`, aucune modification backend  

### Avantage 3 : Maintenance

✅ **Un seul backend a maintenir**  
✅ **Une seule API a securiser**  
✅ **Une seule version a deployer**  
✅ **Moins de couts d'hebergement**  

### Avantage 4 : Flexibilite

✅ **Support multi-langues** (via `formId`)  
✅ **Support multi-marques** (via `formId`)  
✅ **Support multi-produits** (via `formId`)  
✅ **Donnees personnalisees** (via `data`)  

### Avantage 5 : Analytics

✅ **Comparer les performances** entre sites  
✅ **Identifier les formulaires populaires**  
✅ **Detecter les problemes** (formulaire avec peu de soumissions)  
✅ **Optimiser les conversions**  

---

## 7. Exemples de Code Frontend

### Convention de Nommage `formId`

Adoptez une convention claire pour vos `formId` :

```
[site]-[section]-[type]

Exemples :
- corporate-contact-general
- corporate-rh-candidature
- shop-support-retour
- shop-contact-vendeur
- blog-newsletter-signup
- landing-demo-request
```

### Composant Reutilisable React

```jsx
// components/UniversalContactForm.jsx
import React, { useState } from 'react';

function UniversalContactForm({ 
  formId,           // Identifiant unique du formulaire
  apiUrl,           // URL de l'API
  fields = [],      // Champs personnalises
  onSuccess,        // Callback succes
  onError           // Callback erreur
}) {
  const [formData, setFormData] = useState({});
  const [status, setStatus] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    try {
      const response = await fetch(apiUrl, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          formId: formId,
          email: formData.email,
          name: formData.name,
          message: formData.message,
          pageUrl: window.location.href,
          referrer: document.referrer,
          data: formData.customData
        })
      });
      
      const data = await response.json();
      
      if (data.success) {
        setStatus('Message envoye avec succes !');
        setFormData({});
        if (onSuccess) onSuccess(data);
      } else {
        setStatus('Erreur lors de l\'envoi');
        if (onError) onError(data);
      }
    } catch (error) {
      setStatus('Erreur de connexion');
      if (onError) onError(error);
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      {/* Champs dynamiques selon props */}
      {fields.map(field => (
        <div key={field.name}>
          <label>{field.label}</label>
          <input
            type={field.type}
            name={field.name}
            required={field.required}
            onChange={(e) => setFormData({
              ...formData,
              [field.name]: e.target.value
            })}
          />
        </div>
      ))}
      
      <button type="submit">Envoyer</button>
      {status && <p>{status}</p>}
    </form>
  );
}

export default UniversalContactForm;
```

### Utilisation du Composant Reutilisable

```jsx
// pages/Contact.jsx
import UniversalContactForm from '../components/UniversalContactForm';

function ContactPage() {
  return (
    <UniversalContactForm
      formId="corporate-contact-general"
      apiUrl="http://api.monsite.com:8080/api/contact"
      fields={[
        { name: 'email', type: 'email', label: 'Email', required: true },
        { name: 'name', type: 'text', label: 'Nom', required: true },
        { name: 'message', type: 'textarea', label: 'Message', required: false }
      ]}
      onSuccess={(data) => console.log('Succes !', data)}
      onError={(error) => console.error('Erreur !', error)}
    />
  );
}

// pages/Support.jsx
function SupportPage() {
  return (
    <UniversalContactForm
      formId="corporate-support-technique"
      apiUrl="http://api.monsite.com:8080/api/contact"
      fields={[
        { name: 'email', type: 'email', label: 'Email', required: true },
        { name: 'name', type: 'text', label: 'Nom', required: true },
        { name: 'ticketNumber', type: 'text', label: 'Numero de ticket' },
        { name: 'priority', type: 'select', label: 'Priorite', 
          options: ['Basse', 'Moyenne', 'Haute'] },
        { name: 'message', type: 'textarea', label: 'Description du probleme', required: true }
      ]}
    />
  );
}
```

---

## 8. Cas d'Usage Avances

### Cas 1 : Application Multi-Tenant (SaaS)

Chaque client (tenant) a son propre `formId` :

```javascript
// Client ID 1234
{
  "formId": "tenant-1234-support",
  "email": "user@client1234.com"
}

// Client ID 5678
{
  "formId": "tenant-5678-support",
  "email": "user@client5678.com"
}
```

### Cas 2 : A/B Testing

Testez differentes versions de formulaires :

```javascript
// Version A (formulaire court)
{
  "formId": "landing-contact-v1",
  "email": "user@example.com"
}

// Version B (formulaire long)
{
  "formId": "landing-contact-v2",
  "email": "user@example.com"
}

// Analyser ensuite quel formulaire convertit le mieux
```

### Cas 3 : Integration avec CRM

Routage automatique selon le `formId` :

```javascript
// Leads commerciaux → Salesforce
if (formId.includes('sales') || formId.includes('demo')) {
  sendToSalesforce(data);
}

// Support → Zendesk
if (formId.includes('support')) {
  createZendeskTicket(data);
}

// RH → BambooHR
if (formId.includes('rh') || formId.includes('candidature')) {
  sendToBambooHR(data);
}
```

---

## 9. Recapitulatif

### La Force de cette Architecture

```
┌────────────────────────────────────────────────────┐
│                                                    │
│    1 Backend = ∞ Sites + ∞ Formulaires           │
│                                                    │
│  ✅ Aucune modification backend necessaire        │
│  ✅ Evolutif a l'infini                           │
│  ✅ Gestion centralisee                           │
│  ✅ Maintenance simplifiee                        │
│  ✅ Couts reduits                                 │
│                                                    │
└────────────────────────────────────────────────────┘
```

### Comparaison avec Architecture Traditionnelle

| Aspect | Architecture Traditionnelle | Cette Architecture |
|--------|----------------------------|-------------------|
| **Backend par site** | 1 backend par site | 1 backend pour tous |
| **Cout maintenance** | Eleve (N backends) | Faible (1 backend) |
| **Ajout nouveau site** | Deployer nouveau backend | Ajouter un `formId` |
| **Ajout formulaire** | Modifier backend | Ajouter un `formId` |
| **Centralisation** | Difficile | Immediate |
| **Statistiques globales** | Complique | Simple |
| **Evolutivite** | Limitee | Infinie |

---

## Conclusion

Cette architecture est **parfaite** pour :

✅ **Agences web** gerant plusieurs clients  
✅ **Startups** en croissance rapide  
✅ **Entreprises** avec plusieurs sites/marques  
✅ **Applications SaaS** multi-tenant  
✅ **Plateformes** avec ecosystem de services  

**La cle** : Le champ `formId` qui permet une flexibilite totale sans jamais toucher au backend !

---

Exploitez la puissance de cette architecture !

