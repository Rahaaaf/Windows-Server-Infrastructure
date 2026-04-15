# 🖥️ Windows Server Infrastruktur – Projektdokumentation



> Entwicklung und Umsetzung einer skalierbaren Windows-Server-Infrastruktur für ein fiktives IT-Unternehmen.

**Autoren:** Rahaf Alawad  · Dominik Ladek 


---

## 📋 Inhaltsübersicht

- [Projektbeschreibung](#projektbeschreibung)
- [Unternehmensstruktur](#unternehmensstruktur)
- [Infrastruktur-Übersicht](#infrastruktur-übersicht)
- [Implementierte Dienste](#implementierte-dienste)
- [Sicherheit & Gruppenrichtlinien](#sicherheit--gruppenrichtlinien)
- [Technologien](#technologien)
- [Projektphasen](#projektphasen)

---

## 📌 Projektbeschreibung

Das Projekt umfasst den Entwurf und die Implementierung einer **skalierbaren Windows-Server-Infrastruktur** basierend auf **Windows Server 2025 Datacenter**, bestehend aus **7 virtuellen Maschinen** in einer isolierten Sandbox-Umgebung.

### Ziele
- Zentrale Benutzerverwaltung mit **Active Directory Domain Services (AD DS)**
- Bereitstellung von **DHCP**, **DNS**, **File-Server** und **Web-Server**
- Einrichtung von **Failover-Clustering** für hohe Verfügbarkeit
- **Zentrales Monitoring** mit dem Performance Monitor
- Automatisierte Datensicherung und Sicherheitsrichtlinien per **Group Policies**

---

## 🏢 Unternehmensstruktur

```
Geschäftsführung (GL)
├── IT-Abteilung
│   ├── Systemadministration (SA)
│   │   └── Lagerverwaltung (LV)
│   ├── Außendiensttechnik (AT)
│   └── Werkstattteam (WT)
└── Verwaltung
    ├── Personalmanagement (PM)
    └── Vertrieb (V)
```

Die Domäne lautet: `unternehmen.de`

---

## 🖧 Infrastruktur-Übersicht

| VM | Name | IP-Adresse | Rollen & Features | Windows-Version |
|---|---|---|---|---|
| VM1 | 01AD | 220.220.0.10 / .12 | AD DS, DNS, DHCP, Domänencontroller, Print | Server 2025 Datacenter |
| VM2 | Client01 | 220.220.0.27 (dynamisch) | Test-Client | Server 2025 Datacenter |
| VM3 | 03W | 220.220.0.3 | IIS (Webserver), Fileserver | Server 2025 Datacenter |
| VM4 | 04F | 220.220.0.4 | Fileserver, Failover-Cluster (Knoten 1) | Server 2025 Datacenter **Core** |
| VM5 | 04F-2 | 220.220.0.5 | Fileserver, Failover-Cluster (Knoten 2) | Server 2025 Datacenter **Core** |
| VM6 | 02AD | 220.220.0.6 | AD DS, DNS, Domänencontroller (Replikat) | Server 2025 Datacenter |
| VM7 | 07mon | 220.220.0.7 | Monitoring (Performance Monitor) | Server 2025 Datacenter |

**DHCP-Scope:** `220.220.0.10 – 220.220.0.200`  
**Exclusion Range (statisch):** `220.220.0.10 – 220.220.0.20`  
**Failover-Cluster-Name:** `FsCluster01` · IP: `220.220.0.9`

---

## ⚙️ Implementierte Dienste

### 🗂️ Active Directory & DNS
- Domäne `unternehmen.de` mit zwei Domänencontrollern (01AD + 02AD)
- Forward-Lookup-Zone automatisch konfiguriert
- Benutzer und Gruppen in Organisationseinheiten (OUs) strukturiert

### 📡 DHCP
- Scope „Koeln" mit automatischer IP-Vergabe
- Statischer Bereich für Server reserviert

### 📁 Failover File-Server Cluster
```powershell
# Cluster erstellen
New-Cluster -Name FsCluster01 -Node 04F, 04F-2 -StaticAddress 220.220.0.9

# Freigabe einrichten
New-SmbShare -Name "Daten" -Path "E:\Freigaben\Daten" -FullAccess "UNTERNEHMEN\Administrator"

# Failover testen
Move-ClusterGroup -Name "FsFileshare01" -Node "04F-2"
```

### 🌐 Webserver (IIS)
- Microsoft IIS auf VM3 (03W)
- Virtuelles Verzeichnis `/IT-Team` mit Windows-Authentifizierung
- NTFS-Berechtigungen nach Least-Privilege-Prinzip
- TCP-Port 443 (SSL) in der Firewall freigegeben

### 📊 Monitoring
- Windows Performance Monitor auf VM7 (07mon)
- Überwachung von: CPU, RAM, Netzwerk und Festplatten
- Zentrale Überwachung aller Server: 01AD, 02AD, 03W, FsCluster01, Fsfileshare01

---

## 🔒 Sicherheit & Gruppenrichtlinien

| Richtlinie | Beschreibung |
|---|---|
| Passwortrichtlinie | Min. 12 Zeichen, Komplexität, max. 30 Tage, 24 Passwörter History |
| Task-Manager deaktiviert | Verhindert Manipulation an Systemprozessen |
| CD/DVD Schreibschutz | Schutz vor Datendiebstahl und unerlaubter Softwareinstallation |
| Eigenschaften ausblenden | Kein Zugriff auf System-/Remotedesktop-Einstellungen |
| Automatische Updates | Wöchentlich konfiguriert für Betriebssystemsicherheit |
| Schattenkopien (Shadow Copy) | Schutz gegen versehentliches Löschen von Dateien |
| Quota Management | Speicherplatzbegrenzung pro Benutzer |
| SSL Port 443 | Verschlüsselte HTTPS-Kommunikation |

### NTFS-Berechtigungsstufen
- **Vollzugriff** – Lesen, Schreiben, Löschen, Berechtigungen ändern
- **Ändern** – Lesen, Erstellen, Ändern (keine Berechtigung ändern)
- **Lesen** – Nur Lesezugriff

---

## 🛠️ Technologien

![Windows Server 2025](https://img.shields.io/badge/Windows_Server-2025_Datacenter-0078D4?style=for-the-badge&logo=windows&logoColor=white)
![Hyper-V](https://img.shields.io/badge/Hyper--V-Virtualisierung-0078D4?style=for-the-badge&logo=microsoft&logoColor=white)
![Active Directory](https://img.shields.io/badge/Active_Directory-AD_DS-0078D4?style=for-the-badge&logo=microsoft&logoColor=white)
![PowerShell](https://img.shields.io/badge/PowerShell-Konfiguration-5391FE?style=for-the-badge&logo=powershell&logoColor=white)
![IIS](https://img.shields.io/badge/IIS-Webserver-0078D4?style=for-the-badge&logo=microsoft&logoColor=white)

- **Hypervisor:** Microsoft Hyper-V (Virtual Machine Manager)
- **Betriebssystem:** Windows Server 2025 Datacenter (Desktop & Core)
- **Verzeichnisdienst:** Active Directory Domain Services
- **Netzwerkdienste:** DNS, DHCP, SMB
- **Webserver:** Internet Information Services (IIS)
- **Clustering:** Windows Server Failover Clustering
- **Monitoring:** Windows Performance Monitor
- **Skripting:** PowerShell / SConfig

---

## 📅 Projektphasen

```
Phase 1 – Analyse
└── Anforderungsanalyse, technische Möglichkeiten, Grundlagenrecherche

Phase 2 – Planung
└── Infrastrukturkonzept, Netzwerkdesign, VM-Zuweisung, OU-Struktur

Phase 3 – Implementierung
└── Installation aller VMs, Konfiguration aller Serverrollen und -dienste

Phase 4 – Test & Optimierung
└── Failover-Tests, Monitoring, Sicherheitsrichtlinien, Backup
```

---

## 📂 Ordnerstruktur (empfohlen für dieses Repo)

```
windows-server-infrastruktur/
├── README.md
├── docs/
│   └── Projektdokumentation.pdf
├── screenshots/
│   ├── active-directory-struktur.png
│   ├── dns-manager.png
│   ├── failover-cluster.png
│   ├── performance-monitor.png
│   ├── gruppenrichtlinien.png
│   └── webserver-iis.png
└── scripts/
    ├── setup-fileserver.ps1
    ├── setup-cluster.ps1
    └── setup-dhcp.ps1
```

---

##  Eigenständigkeitserklärung

Die Arbeit wurde selbstständig verfasst. Alle verwendeten Quellen sind im Literaturverzeichnis angegeben.


---

*Rheinische Hochschule Köln · Sommersemester 2025*
